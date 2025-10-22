import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';
import '../services/supabase_notification_service.dart';
import '../supabase/supabase_config.dart';
import '../supabase/supabase_service.dart';
import '../utils/logger.dart';
import '../utils/uuid_generator.dart';

class SupabaseLeaveService {
  final SupabaseClient _client = SupabaseService.client;

  /// Submit a new leave request
  Future<String> submitLeaveRequest({
    required String userId,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final leaveRequestData = {
        'user_id': userId,
        'reason': reason,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(SupabaseConfig.leaveRequestsTable)
          .insert(leaveRequestData)
          .select()
          .single();

      Logger.info('SupabaseLeaveService: Leave request submitted successfully');
      return response['id'] as String;
    } catch (e) {
      Logger.error('SupabaseLeaveService: Failed to submit leave request: $e');
      throw Exception('Failed to submit leave request: $e');
    }
  }

  /// Get all leave requests (for admin)
  Future<List<Map<String, dynamic>>> getLeaveRequests() async {
    try {
      final response = await _client
          .from(SupabaseConfig.leaveRequestsTable)
          .select('''
            *,
            users!leave_requests_user_id_fkey(name, email),
            reviewed_by_user:users!leave_requests_reviewed_by_fkey(name, email)
          ''')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger.error('SupabaseLeaveService: Failed to get leave requests: $e');
      throw Exception('Failed to get leave requests: $e');
    }
  }

  /// Get leave requests for a specific user
  Future<List<Map<String, dynamic>>> getUserLeaveRequests(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.leaveRequestsTable)
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger.error(
        'SupabaseLeaveService: Failed to get user leave requests: $e',
      );
      throw Exception('Failed to get user leave requests: $e');
    }
  }

  /// Update leave request status (for admin)
  Future<void> updateLeaveStatus(String requestId, String status) async {
    try {
      if (!['pending', 'approved', 'rejected'].contains(status)) {
        throw Exception('Invalid status: $status');
      }

      // Get current user ID for reviewed_by field
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the leave request details to get the user ID
      final request = await _client
          .from(SupabaseConfig.leaveRequestsTable)
          .select('*, users!leave_requests_user_id_fkey(name)')
          .eq('id', requestId)
          .single();

      await _client
          .from(SupabaseConfig.leaveRequestsTable)
          .update({
            'status': status,
            'reviewed_by': currentUser.id,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      // Send notification based on the status
      final notificationService = SupabaseNotificationService();
      final userId = request['user_id'] as String;
      final startDate = DateTime.parse(
        request['start_date'] as String,
      ).toLocal();
      final endDate = DateTime.parse(request['end_date'] as String).toLocal();

      final formattedStartDate =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final formattedEndDate =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final notification = NotificationModel(
        id: UuidGenerator.generateUuid(),
        title: status == 'approved'
            ? 'Leave Request Approved'
            : 'Leave Request Rejected',
        body: status == 'approved'
            ? 'Your leave request from $formattedStartDate to $formattedEndDate has been approved'
            : 'Your leave request from $formattedStartDate to $formattedEndDate has been rejected',
        type: status == 'approved'
            ? NotificationType.leaveRequestApproved
            : NotificationType.leaveRequestRejected,
        payload: requestId,
        createdAt: DateTime.now(),
        isRead: false,
        userId: userId,
      );

      await notificationService.saveNotification(notification);

      Logger.info(
        'SupabaseLeaveService: Leave request status updated to $status and notification sent',
      );
    } catch (e) {
      Logger.error('SupabaseLeaveService: Failed to update leave status: $e');
      throw Exception('Failed to update leave status: $e');
    }
  }

  /// Delete a leave request
  Future<void> deleteLeaveRequest(String requestId) async {
    try {
      await _client
          .from(SupabaseConfig.leaveRequestsTable)
          .delete()
          .filter('id', 'eq', requestId);

      Logger.info('SupabaseLeaveService: Leave request deleted successfully');
    } catch (e) {
      Logger.error('SupabaseLeaveService: Failed to delete leave request: $e');
      throw Exception('Failed to delete leave request: $e');
    }
  }

  /// Delete all leave requests (admin only)
  Future<void> deleteAllLeaveRequests() async {
    try {
      await _client
          .from(SupabaseConfig.leaveRequestsTable)
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');

      Logger.info(
        'SupabaseLeaveService: All leave requests deleted successfully',
      );
    } catch (e) {
      Logger.error(
        'SupabaseLeaveService: Failed to delete all leave requests: $e',
      );
      throw Exception('Failed to delete all leave requests: $e');
    }
  }

  /// Get latest leave request for a user
  Future<Map<String, dynamic>?> getLatestUserLeaveRequest(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.leaveRequestsTable)
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      Logger.error(
        'SupabaseLeaveService: Failed to get latest user leave request: $e',
      );
      throw Exception('Failed to get latest user leave request: $e');
    }
  }
}
