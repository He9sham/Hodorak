import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/services/service_locator.dart';
import 'package:hodorak/core/theming/styles.dart';
import 'package:hodorak/features/auth/views/widgets/custom_text_field_auth.dart';
import 'package:hodorak/features/auth/views/widgets/label_text_field.dart';
import 'package:hodorak/features/auth/views/widgets/login_button.dart';

class CompanyCreationScreen extends ConsumerStatefulWidget {
  const CompanyCreationScreen({super.key});

  @override
  ConsumerState<CompanyCreationScreen> createState() =>
      _CompanyCreationScreenState();
}

class _CompanyCreationScreenState extends ConsumerState<CompanyCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  bool _isCreating = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _adminNameController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      // Check if company name already exists
      final exists = await supabaseCompanyService.companyNameExists(
        _companyNameController.text.trim(),
      );

      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A company with this name already exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isCreating = false;
        });
        return;
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login screen with the created company
        Navigator.of(context).pop(newCompany);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating company: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Company',
          style: Styles.textSize13Black600.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(20),

                  // Header Text
                  Text(
                    'Create your company profile',
                    style: Styles.textSize13Black600.copyWith(fontSize: 16.sp),
                  ),
                  verticalSpace(8),
                  Text(
                    'Fill in the details below to create your company account.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                  ),

                  verticalSpace(32),

                  // Company Name (Required)
                  LabelTextField(title: 'Company Name *'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _companyNameController,
                    hintText: 'Enter your company name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter company name';
                      }
                      if (value.trim().length < 2) {
                        return 'Company name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),

                  // Description
                  LabelTextField(title: 'Description'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _descriptionController,
                    hintText: 'Brief description of your company (Optional)',
                    maxLines: 3,
                    validator: (value) => null, // Optional field
                  ),

                  verticalSpace(16),

                  // Phone
                  LabelTextField(title: 'Phone Number'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _phoneController,
                    hintText: 'Company phone number (Optional)',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null &&
                          value.trim().isNotEmpty &&
                          value.trim().length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),

                  // Email
                  LabelTextField(title: 'Email'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _emailController,
                    hintText: 'Company email (Optional)',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null &&
                          value.trim().isNotEmpty &&
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),

                  // Admin Name (Required)
                  LabelTextField(title: 'Admin Name *'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _adminNameController,
                    hintText: 'Enter admin full name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter admin name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),

                  // Admin Email (Required)
                  LabelTextField(title: 'Admin Email *'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _adminEmailController,
                    hintText: 'Enter admin email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter admin email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),

                  // Admin Password (Required)
                  LabelTextField(title: 'Admin Password *'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _adminPasswordController,
                    hintText: 'Enter admin password',
                    isObscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter admin password';
                      }
                      if (value.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(40),

                  // Create Company Button
                  CustomButtonAuth(
                    title: 'Create Company',
                    onPressed: _createCompany,
                    isLoading: _isCreating,
                  ),

                  verticalSpace(16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  verticalSpace(20),

                  // Info Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This account will be created as a manager for all company operations',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
