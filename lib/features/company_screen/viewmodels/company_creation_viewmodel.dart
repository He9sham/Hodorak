import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/features/company_screen/models/company_creation_model.dart';

class CompanyCreationState {
  final bool isLoading;
  final String? error;
  final CompanyCreationModel? createdCompany;

  const CompanyCreationState({
    this.isLoading = false,
    this.error,
    this.createdCompany,
  });

  CompanyCreationState copyWith({
    bool? isLoading,
    String? error,
    CompanyCreationModel? createdCompany,
  }) {
    return CompanyCreationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      createdCompany: createdCompany ?? this.createdCompany,
    );
  }
}

class CompanyCreationNotifier extends Notifier<CompanyCreationState> {
  @override
  CompanyCreationState build() {
    return const CompanyCreationState();
  }

  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  // Getters for controllers
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get companyNameController => _companyNameController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get emailController => _emailController;
  TextEditingController get adminNameController => _adminNameController;
  TextEditingController get adminEmailController => _adminEmailController;
  TextEditingController get adminPasswordController => _adminPasswordController;

  // Validation methods
  String? validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter company name';
    }
    if (value.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }
    return null;
  }

  String? validateDescription(String? value) {
    return null; // Optional field
  }

  String? validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty && !value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateAdminName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter admin name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateAdminEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter admin email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateAdminPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter admin password';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Create company method
  Future<bool> createCompany() async {
    if (!_formKey.currentState!.validate()) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if company name already exists
      final exists = await supabaseCompanyService.companyNameExists(
        _companyNameController.text.trim(),
      );

      if (exists) {
        state = state.copyWith(
          isLoading: false,
          error: 'A company with this name already exists',
        );
        return false;
      }

      // Create the company first
      final newCompany = await supabaseCompanyService.createCompany(
        name: _companyNameController.text.trim(),
        adminUserId: null, // This will be updated after user creation
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      // Create the admin user
      await supabaseAuthService.signUp(
        email: _adminEmailController.text.trim(),
        password: _adminPasswordController.text.trim(),
        name: _adminNameController.text.trim().isEmpty
            ? 'Admin'
            : _adminNameController.text.trim(),
        jobTitle: 'Administrator',
        department: 'Management',
        phone: '',
        nationalId: '',
        gender: '',
        companyId: newCompany.id,
        isAdmin: true,
      );

      state = state.copyWith(
        isLoading: false,
        createdCompany: CompanyCreationModel(
          companyName: _companyNameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          adminName: _adminNameController.text.trim().isEmpty
              ? 'Admin'
              : _adminNameController.text.trim(),
          adminEmail: _adminEmailController.text.trim(),
          adminPassword: _adminPasswordController.text.trim(),
        ),
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error creating company , please try again.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
  }
}

// Provider for the notifier
final companyCreationNotifierProvider =
    NotifierProvider<CompanyCreationNotifier, CompanyCreationState>(() {
      return CompanyCreationNotifier();
    });
