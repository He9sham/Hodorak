import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/providers/location_provider.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/services/biometric_auth_service.dart';
import 'package:hodorak/core/services/firebase_messaging_service.dart';
import 'package:hodorak/core/services/supabase_attendance_service.dart';
import 'package:hodorak/features/home/views/widgets/leave_request_form.dart';

class AttendanceButtons extends ConsumerStatefulWidget {
  final VoidCallback? onLeaveRequestSubmitted;

  const AttendanceButtons({super.key, this.onLeaveRequestSubmitted});

  @override
  ConsumerState<AttendanceButtons> createState() => _AttendanceButtonsState();
}

class _AttendanceButtonsState extends ConsumerState<AttendanceButtons> {
  bool _isLoading = false;
  bool _isCheckedIn = false;
  late Timer _timer;
  String _currentTime = '';
  String _currentDate = '';
  final BiometricAuthService _biometricAuthService = BiometricAuthService();

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
    _checkAttendanceStatus();
  }

  Future<void> _checkAttendanceStatus() async {
    try {
      final authState = ref.read(supabaseAuthProvider);
      if (!authState.isAuthenticated || authState.user?.id == null) {
        return;
      }

      final attendanceService = SupabaseAttendanceService();
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingAttendance = await attendanceService.getUserAttendance(
        userId: authState.user!.id,
        startDate: startOfDay,
        endDate: endOfDay,
      );

      if (mounted) {
        setState(() {
          // Check if there's an active check-in (no check-out)
          _isCheckedIn = existingAttendance.any(
            (record) => record.checkOut == null,
          );
        });
      }
    } catch (e) {
      // Silently fail - user can still try to check in
    }
  }

  // Permission checking removed - all users allowed to use attendance features

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = _formatTime(now);
      _currentDate = _formatDate(now);
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;

    return '$weekday, $month $day, $year';
  }

  Future<void> _handleCheckIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(supabaseAuthProvider);
      final attendanceService = SupabaseAttendanceService();

      if (!authState.isAuthenticated || authState.user?.id == null) {
        _showErrorMessage('You are not authenticated. Please login again.');
        return;
      }

      // Refresh workplace location state and validate location
      await ref.read(locationValidationProvider.notifier).checkInitialState();
      await ref.read(locationValidationProvider.notifier).validateLocation();
      final locationState = ref.read(locationValidationProvider);

      if (!locationState.hasWorkplaceLocation) {
        _showErrorMessage('No workplace location has been set by admin.');
        return;
      }

      if (!locationState.isAtWorkplace) {
        _showErrorMessage(
          locationState.errorMessage ??
              'You must be at the workplace location to check in.',
        );
        return;
      }

      // Perform biometric authentication
      try {
        final bool isAuthenticated = await _biometricAuthService.authenticate(
          action: 'check in',
        );
        if (!isAuthenticated) {
          _showErrorMessage('Authentication failed. Please try again.');
          return;
        }
      } catch (e) {
        _showErrorMessage('Authentication failed. Please try again.');
        return;
      }

      // Get current location for attendance
      final locationService = ref.read(locationServiceProvider);
      final currentLocation = await locationService.getCurrentLocation();

      // Perform check in using Supabase
      await attendanceService.checkIn(
        userId: authState.user!.id,
        location: currentLocation?.toString(),
        latitude: currentLocation?.latitude,
        longitude: currentLocation?.longitude,
      );

      // Send check-in notification
      final messagingService = FirebaseMessagingService();
      final username =
          authState.user?.name ?? authState.user?.email.split('@')[0] ?? 'User';
      await messagingService.showCheckInNotification(
        userId: authState.user!.id,
        username: username,
        location: currentLocation?.toString(),
      );

      // Refresh attendance data through the provider (optional)
      _refreshAttendanceData();

      // Update checked in state
      setState(() {
        _isCheckedIn = true;
      });

      _showSuccessMessage('Check In successful');
    } catch (e) {
      _showErrorMessage('Check In failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCheckOut() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(supabaseAuthProvider);
      final attendanceService = SupabaseAttendanceService();

      if (!authState.isAuthenticated || authState.user?.id == null) {
        _showErrorMessage('You are not authenticated. Please login again.');
        return;
      }

      // Refresh workplace location state and validate location
      await ref.read(locationValidationProvider.notifier).checkInitialState();
      await ref.read(locationValidationProvider.notifier).validateLocation();
      final locationState = ref.read(locationValidationProvider);

      if (!locationState.hasWorkplaceLocation) {
        _showErrorMessage('No workplace location has been set by admin.');
        return;
      }

      if (!locationState.isAtWorkplace) {
        _showErrorMessage(
          locationState.errorMessage ??
              'You must be at the workplace location to check out.',
        );
        return;
      }

      // Perform biometric authentication
      try {
        final bool isAuthenticated = await _biometricAuthService.authenticate(
          action: 'check out',
        );
        if (!isAuthenticated) {
          _showErrorMessage('Authentication failed. Please try again.');
          return;
        }
      } catch (e) {
        _showErrorMessage('Authentication failed. Please try again.');
        return;
      }

      // Get current location for attendance
      final locationService = ref.read(locationServiceProvider);
      final currentLocation = await locationService.getCurrentLocation();

      // Perform check out using Supabase
      await attendanceService.checkOut(
        userId: authState.user!.id,
        location: currentLocation?.toString(),
        latitude: currentLocation?.latitude,
        longitude: currentLocation?.longitude,
      );

      // Send check-out notification
      final messagingService = FirebaseMessagingService();
      final username =
          authState.user?.name ?? authState.user?.email.split('@')[0] ?? 'User';
      await messagingService.showCheckOutNotification(
        userId: authState.user!.id,
        username: username,
        location: currentLocation?.toString(),
      );

      // Refresh attendance data through the provider (optional)
      _refreshAttendanceData();

      // Update checked in state
      setState(() {
        _isCheckedIn = false;
      });

      _showSuccessMessage('Check Out successful');
    } catch (e) {
      // Check if the error is because user hasn't checked in
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('no rows') ||
          errorMessage.contains('not found') ||
          errorMessage.contains('postgrest')) {
        _showErrorMessage('Check in must be registered first');
      } else {
        _showErrorMessage('Check Out failed: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Permission error dialog removed - all users allowed to use attendance features

  Future<void> _handleTemporaryLeave() async {
    if (_isLoading) return;

    final authState = ref.read(supabaseAuthProvider);
    if (!authState.isAuthenticated || authState.user?.id == null) {
      _showErrorMessage('You are not authenticated. Please login again.');
      return;
    }

    // Show the new Supabase leave request form
    await showDialog(
      context: context,
      builder: (context) => LeaveRequestForm(
        userId: authState.user!.id,
        onSubmitted: () {
          Navigator.of(context).pop();
          widget.onLeaveRequestSubmitted?.call();
        },
      ),
    );
  }

  void _refreshAttendanceData() {
    // Attendance data refresh is now handled by the calendar system
    // No additional refresh needed here
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Attendance',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xff8C9F5F),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Date and Time Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xff8C9F5F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  _currentTime,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8C9F5F),
                  ),
                ),
                Text(
                  _currentDate,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_isLoading || _isCheckedIn)
                      ? null
                      : _handleCheckIn,
                  icon: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.login,
                          color: _isCheckedIn ? Colors.grey[400] : Colors.white,
                        ),
                  label: Text(
                    _isCheckedIn ? 'Already Checked In' : 'Check In',
                    style: TextStyle(
                      color: _isCheckedIn ? Colors.grey[400] : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCheckedIn
                        ? Colors.grey[300]
                        : Color(0xff8C9F5F),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCheckOut,
                  icon: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    'Check Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Temporary Leave Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleTemporaryLeave,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.schedule, color: Colors.white),
              label: Text(
                'Request Temporary Leave',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
