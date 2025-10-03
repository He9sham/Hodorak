import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/models/leave_request.dart';
import 'package:hodorak/core/services/service_locator.dart';

class LeaveStatusDisplay extends ConsumerStatefulWidget {
  final String userId;

  const LeaveStatusDisplay({super.key, required this.userId});

  @override
  ConsumerState<LeaveStatusDisplay> createState() => _LeaveStatusDisplayState();
}

class _LeaveStatusDisplayState extends ConsumerState<LeaveStatusDisplay> {
  LeaveRequest? _latestRequest;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLatestRequest();
  }

  Future<void> _loadLatestRequest() async {
    try {
      final request = await firebaseLeaveService.getLatestUserLeaveRequest(
        widget.userId,
      );
      if (mounted) {
        setState(() {
          _latestRequest = request;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'approved':
        return 'Your request has been approved';
      case 'rejected':
        return 'Your request has been rejected';
      case 'pending':
        return 'Your request is pending';
      default:
        return 'Unknown status';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading leave status...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error loading leave status: $_error',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_latestRequest == null) {
      return const SizedBox.shrink(); // Don't show anything if no request
    }

    final statusColor = _getStatusColor(_latestRequest!.status);
    final statusIcon = _getStatusIcon(_latestRequest!.status);
    final statusMessage = _getStatusMessage(_latestRequest!.status);

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24.sp),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
            if (_latestRequest!.status != 'pending') ...[
              const SizedBox(height: 8),
              Text(
                'Leave Period: ${_latestRequest!.startDate.day}/${_latestRequest!.startDate.month}/${_latestRequest!.startDate.year} - ${_latestRequest!.endDate.day}/${_latestRequest!.endDate.month}/${_latestRequest!.endDate.year}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp),
              ),
              const SizedBox(height: 4),
              Text(
                'Reason: ${_latestRequest!.reason}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Submitted on: ${_latestRequest!.createdAt.day}/${_latestRequest!.createdAt.month}/${_latestRequest!.createdAt.year}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
