import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/features/shift_management/data/repositories/shift_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserShiftState {
  final Map<String, dynamic>? shiftData;
  final bool isLoading;
  final String? error;

  const UserShiftState({this.shiftData, this.isLoading = false, this.error});

  UserShiftState copyWith({
    Map<String, dynamic>? shiftData,
    bool? isLoading,
    String? error,
  }) {
    return UserShiftState(
      shiftData: shiftData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserShiftViewModel extends Notifier<UserShiftState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  UserShiftState build() {
    Future.microtask(() => loadUserShift());
    return const UserShiftState(isLoading: true);
  }

  Future<void> loadUserShift() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(shiftRepositoryProvider);
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return;
      }

      final today = DateTime.now();
      final shiftData = await repository.getEmployeeShiftForDate(userId, today);

      state = UserShiftState(
        shiftData: shiftData,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userShiftViewModelProvider =
    NotifierProvider<UserShiftViewModel, UserShiftState>(
      UserShiftViewModel.new,
    );
