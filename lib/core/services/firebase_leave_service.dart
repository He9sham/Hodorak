import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hodorak/core/models/leave_request.dart';
import 'package:hodorak/core/services/service_locator.dart';

class FirebaseLeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'requests';

  /// Submit a new leave request
  Future<String> submitLeaveRequest({
    required String userId,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final leaveRequest = LeaveRequest(
        id: '', // Will be set by Firestore
        userId: userId,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_collectionName)
          .add(leaveRequest.toMap());

      // Show notification to user that request was submitted
      try {
        await notificationService.showLeaveRequestSubmittedNotification(
          userId: userId,
        );
      } catch (e) {
        // Log error but don't fail the leave request submission
        debugPrint('Failed to show leave request submitted notification: $e');
      }

      // Show notification to manager (if admin is logged in)
      try {
        final userProfile = await odooService.getUserProfile();
        if (userProfile != null && userProfile['name'] != null) {
          await notificationService.showManagerLeaveRequestNotification(
            username: userProfile['name'],
          );
        } else {
          // If we can't get user profile, still show notification with userId
          await notificationService.showManagerLeaveRequestNotification(
            username: 'User $userId',
          );
        }
      } catch (e) {
        // Log error but don't fail the leave request submission
        debugPrint('Failed to show manager notification: $e');
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit leave request: $e');
    }
  }

  /// Get all leave requests (for admin)
  Stream<List<LeaveRequest>> getLeaveRequests() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => LeaveRequest.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get leave requests for a specific user
  Stream<List<LeaveRequest>> getUserLeaveRequests(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs
              .map((doc) => LeaveRequest.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt in descending order client-side
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  /// Get the latest leave request for a user
  Future<LeaveRequest?> getLatestUserLeaveRequest(String userId) async {
    try {
      // Get all requests for the user and sort them client-side to avoid composite index
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Convert to LeaveRequest objects and sort by createdAt
        final requests = querySnapshot.docs
            .map((doc) => LeaveRequest.fromMap(doc.data(), doc.id))
            .toList();

        // Sort by createdAt in descending order and return the first one
        requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return requests.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get latest leave request: $e');
    }
  }

  /// Update leave request status (for admin)
  Future<void> updateLeaveStatus(String requestId, String status) async {
    try {
      if (!['pending', 'approved', 'rejected'].contains(status)) {
        throw Exception('Invalid status: $status');
      }

      // Get the leave request to get the userId before updating
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(requestId)
          .get();
      if (!docSnapshot.exists) {
        throw Exception('Leave request not found');
      }

      final leaveRequestData = docSnapshot.data()!;
      final userId = leaveRequestData['userId'] as String;

      await _firestore.collection(_collectionName).doc(requestId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Show appropriate notification based on status
      try {
        if (status == 'approved') {
          await notificationService.showLeaveRequestApprovedNotification(
            userId: userId,
          );
        } else if (status == 'rejected') {
          await notificationService.showLeaveRequestRejectedNotification(
            userId: userId,
          );
        }
      } catch (e) {
        // Log error but don't fail the status update
        debugPrint('Failed to show leave status notification: $e');
      }
    } catch (e) {
      throw Exception('Failed to update leave status: $e');
    }
  }

  /// Delete a leave request
  Future<void> deleteLeaveRequest(String requestId) async {
    try {
      await _firestore.collection(_collectionName).doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to delete leave request: $e');
    }
  }

  /// Delete all leave requests
  Future<void> deleteAllLeaveRequests() async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore.collection(_collectionName).get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all leave requests: $e');
    }
  }
}
