import 'package:hodorak/core/models/supabase_user.dart';

enum UserManagementStateType { initial, loading, success, error, empty }

class UserManagementState {
  final UserManagementStateType type;
  final List<SupabaseUser> users;
  final String? error;
  final bool isResettingPassword;
  final bool isDeletingUser;

  const UserManagementState({
    this.type = UserManagementStateType.initial,
    this.users = const [],
    this.error,
    this.isResettingPassword = false,
    this.isDeletingUser = false,
  });

  UserManagementState copyWith({
    UserManagementStateType? type,
    List<SupabaseUser>? users,
    String? error,
    bool? isResettingPassword,
    bool? isDeletingUser,
  }) {
    return UserManagementState(
      type: type ?? this.type,
      users: users ?? this.users,
      error: error ?? this.error,
      isResettingPassword: isResettingPassword ?? this.isResettingPassword,
      isDeletingUser: isDeletingUser ?? this.isDeletingUser,
    );
  }

  bool get isLoading => type == UserManagementStateType.loading;
  bool get isSuccess => type == UserManagementStateType.success;
  bool get isError => type == UserManagementStateType.error;
  bool get isEmpty => type == UserManagementStateType.empty;
  bool get hasUsers => users.isNotEmpty;
}
