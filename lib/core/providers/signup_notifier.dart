import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/odoo_service/odoo_http_service.dart';

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

class SignUpNotifier extends Notifier<SignUpState> {
  final OdooHttpService _service;
  SignUpNotifier(this._service);

  @override
  SignUpState build() {
    return const SignUpState();
  }

  Future<void> signUpEmployee({
    required String name,
    required String email,
    required String password,
    required String jobTitle,
    required String department,
    required String phone,
    required String nationalId,
    required String gender,
  }) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final id = await _service.signUpEmployee(
        name: name,
        email: email,
        password: password,
        jobTitle: jobTitle,
        department: department,
        phone: phone,
        nationalId: nationalId,
        gender: gender,
      );
      state = state.copyWith(
        isLoading: false,
        message: 'User created with id $id',
      );
    } catch (e) {
      String errorMessage = e.toString();

      // Handle network connectivity errors specifically
      if (e.toString().contains('Network error') ||
          e.toString().contains('No internet connection') ||
          e.toString().contains('HTTP error')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      } else if (e.toString().contains('Only admins can create accounts.')) {
        errorMessage = 'Only admins can create accounts.';
      } else if (e.toString().contains('Access denied')) {
        errorMessage =
            'Access denied. Only administrators can create employee accounts.';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }
}

final signUpNotifierProvider = NotifierProvider<SignUpNotifier, SignUpState>(
  () {
    final service = OdooHttpService();
    return SignUpNotifier(service);
  },
);
