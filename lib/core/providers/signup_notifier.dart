import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';
import 'package:hodorak/core/providers/login_notifier.dart';

class SignUpState {
  final bool isLoading;
  final String? error;
  final String? message;

  const SignUpState({this.isLoading = false, this.error, this.message});

  SignUpState copyWith({bool? isLoading, String? error, String? message}) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
    );
  }
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  final OdooHttpService _service;
  SignUpNotifier(this._service) : super(const SignUpState());

  Future<void> signUpEmployee({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final id = await _service.signUpEmployee(
        name: name,
        email: email,
        password: password,
      );
      state = state.copyWith(
        isLoading: false,
        message: 'User created with id $id',
      );
    } catch (e) {
      final msg = e.toString().contains('Only admins can create accounts.')
          ? ''
          : e.toString();
      state = state.copyWith(isLoading: false, error: msg);
    }
  }
}

final signUpNotifierProvider =
    StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
      final service = ref.read(odooHttpServiceProvider);
      return SignUpNotifier(service);
    });
