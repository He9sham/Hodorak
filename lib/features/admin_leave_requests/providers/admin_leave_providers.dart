import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/leave_request.dart';
import 'package:hodorak/core/services/firebase_leave_service.dart';
import 'package:hodorak/core/services/service_locator.dart';

// Provider for Firebase Leave Service
final firebaseLeaveServiceProvider = Provider<FirebaseLeaveService>((ref) {
  return firebaseLeaveService;
});

// Provider for leave requests stream
final leaveRequestsStreamProvider = StreamProvider<List<LeaveRequest>>((ref) {
  final service = ref.watch(firebaseLeaveServiceProvider);
  return service.getLeaveRequests();
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
  final service = ref.watch(firebaseLeaveServiceProvider);
  final processingNotifier = ref.watch(processingRequestsProvider.notifier);
  final deleteAllLoadingNotifier = ref.watch(deleteAllLoadingProvider.notifier);
  return LeaveRequestActions(
    service,
    processingNotifier,
    deleteAllLoadingNotifier,
  );
});

// Class for handling leave request actions
class LeaveRequestActions {
  final FirebaseLeaveService _service;
  final ProcessingRequestsNotifier _processingNotifier;
  final DeleteAllLoadingNotifier _deleteAllLoadingNotifier;

  LeaveRequestActions(
    this._service,
    this._processingNotifier,
    this._deleteAllLoadingNotifier,
  );

  Future<void> updateLeaveStatus(String requestId, String status) async {
    _processingNotifier.setProcessing(requestId, true);

    try {
      await _service.updateLeaveStatus(requestId, status);
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
