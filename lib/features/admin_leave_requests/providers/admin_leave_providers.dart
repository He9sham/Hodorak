import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/leave_request.dart';
import 'package:hodorak/core/services/firebase_messaging_service.dart';
import 'package:hodorak/core/services/supabase_auth_service.dart';
import 'package:hodorak/core/services/supabase_leave_service.dart';

// Provider for Supabase Leave Service
final supabaseLeaveServiceProvider = Provider<SupabaseLeaveService>((ref) {
  return SupabaseLeaveService();
});

// Provider for Supabase Auth Service
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

// Provider for Firebase Messaging Service
final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((
  ref,
) {
  return FirebaseMessagingService();
});

// Provider for leave requests
final leaveRequestsProvider = FutureProvider<List<LeaveRequest>>((ref) async {
  final service = ref.watch(supabaseLeaveServiceProvider);
  final requests = await service.getLeaveRequests();
  return requests.map((request) => LeaveRequest.fromJson(request)).toList();
});

// Provider for processing requests state
final processingRequestsProvider =
    NotifierProvider<ProcessingRequestsNotifier, Map<String, bool>>(() {
      return ProcessingRequestsNotifier();
    });

// Provider for delete all loading state
final deleteAllLoadingProvider =
    NotifierProvider<DeleteAllLoadingNotifier, bool>(() {
      return DeleteAllLoadingNotifier();
    });

// Note: User names are now fetched directly in the leave requests query
// No separate userNameProvider needed

// Notifier for managing processing state
class ProcessingRequestsNotifier extends Notifier<Map<String, bool>> {
  ProcessingRequestsNotifier();

  @override
  Map<String, bool> build() {
    return {};
  }

  void setProcessing(String requestId, bool isProcessing) {
    state = {...state, requestId: isProcessing};
  }

  bool isProcessing(String requestId) {
    return state[requestId] ?? false;
  }

  void clearProcessing(String requestId) {
    final newState = Map<String, bool>.from(state);
    newState.remove(requestId);
    state = newState;
  }
}

// Notifier for delete all loading state
class DeleteAllLoadingNotifier extends Notifier<bool> {
  DeleteAllLoadingNotifier();

  @override
  bool build() {
    return false;
  }

  void setLoading(bool loading) {
    state = loading;
  }
}

// Provider for leave request actions
final leaveRequestActionsProvider = Provider<LeaveRequestActions>((ref) {
  final service = ref.watch(supabaseLeaveServiceProvider);
  final firebaseMessagingService = ref.watch(firebaseMessagingServiceProvider);
  final processingNotifier = ref.watch(processingRequestsProvider.notifier);
  final deleteAllLoadingNotifier = ref.watch(deleteAllLoadingProvider.notifier);
  return LeaveRequestActions(
    service,
    firebaseMessagingService,
    processingNotifier,
    deleteAllLoadingNotifier,
  );
});

// Class for handling leave request actions
class LeaveRequestActions {
  final SupabaseLeaveService _service;
  final FirebaseMessagingService _firebaseMessagingService;
  final ProcessingRequestsNotifier _processingNotifier;
  final DeleteAllLoadingNotifier _deleteAllLoadingNotifier;

  LeaveRequestActions(
    this._service,
    this._firebaseMessagingService,
    this._processingNotifier,
    this._deleteAllLoadingNotifier,
  );

  Future<void> updateLeaveStatus(String requestId, String status) async {
    _processingNotifier.setProcessing(requestId, true);

    try {
      await _service.updateLeaveStatus(requestId, status);

      // Show appropriate notification based on status
      switch (status) {
        case 'approved':
          await _firebaseMessagingService.showLeaveRequestApprovedNotification(
            userId: requestId,
          );
          break;
        case 'rejected':
          await _firebaseMessagingService.showLeaveRequestRejectedNotification(
            userId: requestId,
          );
          break;
      }
    } finally {
      _processingNotifier.setProcessing(requestId, false);
    }
  }

  Future<void> approveRequest(String requestId) async {
    await updateLeaveStatus(requestId, 'approved');
  }

  Future<void> rejectRequest(String requestId) async {
    await updateLeaveStatus(requestId, 'rejected');
  }

  Future<void> deleteAllRequests() async {
    _deleteAllLoadingNotifier.setLoading(true);

    try {
      await _service.deleteAllLeaveRequests();
    } finally {
      _deleteAllLoadingNotifier.setLoading(false);
    }
  }
}
