import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/company_location_provider.dart'
    as company_location;
import 'package:hodorak/core/providers/location_provider.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/services/biometric_auth_service.dart';
import 'package:hodorak/core/services/supabase_attendance_service.dart';
import 'package:hodorak/core/services/supabase_notification_service.dart';
import 'package:hodorak/features/home/views/widgets/leave_request_form.dart';

// Scale animation button wrapper
class ScaleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const ScaleButton({super.key, this.onPressed, required this.child});

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        _controller.reverse();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

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

      // Refresh company location state and validate location
      await ref
          .read(company_location.companyLocationProvider.notifier)
          .refresh();
      final companyLocationState = ref.read(
        company_location.companyLocationProvider,
      );

      if (!companyLocationState.hasLocation) {
        _showErrorMessage('No workplace location has been set by admin.');
        return;
      }

      // Check if user can check in based on distance from company location
      final canCheckIn = await ref
          .read(company_location.companyLocationProvider.notifier)
          .canCheckIn();
      if (!canCheckIn) {
        final distance = await ref
            .read(company_location.companyLocationProvider.notifier)
            .getDistanceToCompanyLocation();
        final distanceText = distance != null
            ? ' (${distance.toInt()}m away)'
            : '';
        _showErrorMessage(
          'You must be at of the workplace location to check in.$distanceText',
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

      // Send check-in notification to Supabase (cross-device)
      final supabaseNotificationService = SupabaseNotificationService();
      final username =
          authState.user?.name ?? authState.user?.email.split('@')[0] ?? 'User';
      await supabaseNotificationService.sendCheckInNotification(
        userId: authState.user!.id,
        username: username,
        location: currentLocation?.toString(),
      );
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

      // Refresh company location state and validate location
      await ref
          .read(company_location.companyLocationProvider.notifier)
          .refresh();
      final companyLocationState = ref.read(
        company_location.companyLocationProvider,
      );

      if (!companyLocationState.hasLocation) {
        _showErrorMessage('No workplace location has been set by admin.');
        return;
      }

      // Check if user can check out based on distance from company location
      final canCheckIn = await ref
          .read(company_location.companyLocationProvider.notifier)
          .canCheckIn();
      if (!canCheckIn) {
        final distance = await ref
            .read(company_location.companyLocationProvider.notifier)
            .getDistanceToCompanyLocation();
        final distanceText = distance != null
            ? ' (${distance.toInt()}m away)'
            : '';
        _showErrorMessage(
          'You must be at meters of the workplace location to check out.$distanceText',
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

      // Send check-out notification to Supabase (cross-device)
      final supabaseNotificationService = SupabaseNotificationService();
      final username =
          authState.user?.name ?? authState.user?.email.split('@')[0] ?? 'User';
      await supabaseNotificationService.sendCheckOutNotification(
        userId: authState.user!.id,
        username: username,
        location: currentLocation?.toString(),
      );

      // Refresh attendance data through the provider (optional)

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: -4,
            blurRadius: 20,
            offset: const Offset(0, 4),
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
          verticalSpace(12),
          // Date and Time Display with Enhanced Styling
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xff8C9F5F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  spreadRadius: -2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated fade for clock display
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _currentTime,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight:
                          FontWeight.w600, // Changed from bold to SemiBold
                      color: Color(0xff8C9F5F),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                verticalSpace(6),
                Text(
                  _currentDate,
                  style: TextStyle(
                    fontSize: 12.sp, // Increased from 10sp to 12sp
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          verticalSpace(16),
          Row(
            children: [
              Expanded(
                child: ScaleButton(
                  onPressed: (_isLoading || _isCheckedIn)
                      ? null
                      : _handleCheckIn,
                  child: ElevatedButton.icon(
                    onPressed: (_isLoading || _isCheckedIn)
                        ? null
                        : _handleCheckIn,
                    icon: _isLoading
                        ? SizedBox(
                            width: 14.4.w, // Reduced by 10% from 16
                            height: 14.4.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.login,
                            size: 18.4, // Reduced by 10%
                            color: _isCheckedIn
                                ? Colors.grey[400]
                                : Colors.white,
                          ),
                    label: Text(
                      _isCheckedIn ? 'Already Checked In' : 'Check In',
                      style: TextStyle(
                        color: _isCheckedIn ? Colors.grey[400] : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCheckedIn
                          ? Colors.grey[300]
                          : Color(0xff8C9F5F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16), // Increased from 12 to 16
              Expanded(
                child: ScaleButton(
                  onPressed: _isLoading ? null : _handleCheckOut,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleCheckOut,
                    icon: _isLoading
                        ? SizedBox(
                            width: 14.4, // Reduced by 10% from 16
                            height: 14.4,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.logout,
                            size: 18.4, // Reduced by 10%
                            color: Colors.white,
                          ),
                    label: Text(
                      'Check Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Temporary Leave Button with Gradient
          ScaleButton(
            onPressed: _isLoading ? null : _handleTemporaryLeave,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orange.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    spreadRadius: -2,
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleTemporaryLeave,
                icon: _isLoading
                    ? SizedBox(
                        width: 14.4,
                        height: 14.4,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.request_quote,
                        size: 18.4,
                        color: Colors.white,
                      ),
                label: Text(
                  'Request Temporary Leave',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
