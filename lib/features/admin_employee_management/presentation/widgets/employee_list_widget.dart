import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/features/admin_employee_management/presentation/viewmodels/sign_up_viewmodel.dart';
import 'package:hodorak/features/admin_employee_management/presentation/widgets/sign_up_gender_dropdown.dart';
import 'package:hodorak/features/admin_employee_management/presentation/widgets/sign_up_text_field.dart';
import 'package:hodorak/features/auth/views/widgets/login_button.dart';

class EmployeeListWidget extends ConsumerStatefulWidget {
  const EmployeeListWidget({super.key});

  @override
  ConsumerState<EmployeeListWidget> createState() => _EmployeeListWidgetState();
}

class _EmployeeListWidgetState extends ConsumerState<EmployeeListWidget> {
  List<SupabaseUser> _employees = [];
  bool _isLoading = true;
  String? _error;
  bool _showAddEmployeeForm = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final employees = await ref
          .read(supabaseAuthProvider.notifier)
          .getCompanyEmployees();
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleAddEmployeeForm() {
    setState(() {
      _showAddEmployeeForm = !_showAddEmployeeForm;
    });
  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    final signUpViewModel = ref.read(signUpViewModelProvider);

    try {
      await ref
          .read(supabaseAuthProvider.notifier)
          .createEmployee(
            name: signUpViewModel.nameController.text.trim(),
            email: signUpViewModel.emailController.text.trim(),
            password: signUpViewModel.passwordController.text.trim(),
            jobTitle: signUpViewModel.jobTitleController.text.trim(),
            department: signUpViewModel.departmentController.text.trim(),
            phone: signUpViewModel.phoneController.text.trim(),
            nationalId: signUpViewModel.nationalIdController.text.trim(),
            gender: signUpViewModel.state.gender,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Employee created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );

        // Clear the form
        signUpViewModel.nameController.clear();
        signUpViewModel.emailController.clear();
        signUpViewModel.passwordController.clear();
        signUpViewModel.jobTitleController.clear();
        signUpViewModel.departmentController.clear();
        signUpViewModel.phoneController.clear();
        signUpViewModel.nationalIdController.clear();
        signUpViewModel.updateGender(null);

        // Hide the form and refresh the list
        setState(() {
          _showAddEmployeeForm = false;
        });
        _loadEmployees();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating employee: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Employees'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          // Floating Add Employee Button
          if (!_showAddEmployeeForm)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: _toggleAddEmployeeForm,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Employee'),
              ),
            ),
          // Floating Close Form Button
          if (_showAddEmployeeForm)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _toggleAddEmployeeForm,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: const Icon(Icons.close),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Add Employee Form (expandable)
        if (_showAddEmployeeForm) _buildAddEmployeeForm(),

        // Employee List
        Expanded(child: _buildEmployeeList()),
      ],
    );
  }

  Widget _buildAddEmployeeForm() {
    final signUpViewModel = ref.watch(signUpViewModelProvider);
    final authState = ref.watch(supabaseAuthProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_add, color: Colors.blue),
                  horizontalSpace(8),
                  Text(
                    'Add New Employee',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              verticalSpace(16),

              // Name and Email Row
              Row(
                children: [
                  Expanded(
                    child: SignUpTextField(
                      controller: signUpViewModel.nameController,
                      hintText: 'Full Name',
                      label: 'Full Name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      onChanged: signUpViewModel.updateName,
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: SignUpTextField(
                      controller: signUpViewModel.emailController,
                      hintText: 'Email',
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (!value.contains('@')) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                      onChanged: signUpViewModel.updateEmail,
                    ),
                  ),
                ],
              ),
              verticalSpace(12),

              // Job Title and Department Row
              Row(
                children: [
                  Expanded(
                    child: SignUpTextField(
                      controller: signUpViewModel.jobTitleController,
                      hintText: 'Job Title',
                      label: 'Job Title',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      onChanged: signUpViewModel.updateJobTitle,
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: SignUpTextField(
                      controller: signUpViewModel.departmentController,
                      hintText: 'Department',
                      label: 'Department',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      onChanged: signUpViewModel.updateDepartment,
                    ),
                  ),
                ],
              ),
              verticalSpace(12),

              // Phone and National ID Row
              Row(
                children: [
                  Expanded(
                    child: SignUpTextField(
                      controller: signUpViewModel.phoneController,
                      hintText: 'Phone Number',
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      onChanged: signUpViewModel.updatePhone,
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: SignUpTextField(
                      controller: signUpViewModel.nationalIdController,
                      hintText: 'National ID',
                      label: 'National ID',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      onChanged: signUpViewModel.updateNationalId,
                    ),
                  ),
                ],
              ),
              verticalSpace(12),

              // Gender and Password Row
              Row(
                children: [
                  Expanded(
                    child: SignUpGenderDropdown(
                      selectedGender: signUpViewModel.state.gender.isEmpty
                          ? null
                          : signUpViewModel.state.gender,
                      onChanged: signUpViewModel.updateGender,
                      errorText: null,
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: SignUpTextField(
                      controller: signUpViewModel.passwordController,
                      hintText: 'Password',
                      label: 'Password',
                      isObscureText: signUpViewModel.state.obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          signUpViewModel.state.obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: signUpViewModel.togglePasswordVisibility,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 6) {
                          return 'Min 6 chars';
                        }
                        return null;
                      },
                      onChanged: signUpViewModel.updatePassword,
                    ),
                  ),
                ],
              ),
              verticalSpace(16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleAddEmployeeForm,
                      child: const Text('Cancel'),
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    flex: 2,
                    child: CustomButtonAuth(
                      title: 'Create Employee',
                      onPressed: _createEmployee,
                      isLoading: authState.isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            verticalSpace(16),
            Text(
              'Error loading employees',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            verticalSpace(8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            verticalSpace(16),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            verticalSpace(16),
            Text(
              'No employees found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            verticalSpace(8),
            Text(
              'Add your first employee to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            verticalSpace(16),
            Text(
              'Use the floating button below to add employees',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ), // Extra bottom padding for FAB
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: employee.isAdmin ? Colors.blue : Colors.green,
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : 'E',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                employee.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.email),
                  if (employee.jobTitle != null) Text(employee.jobTitle!),
                  if (employee.department != null) Text(employee.department!),
                ],
              ),
              trailing: employee.isAdmin
                  ? const Chip(
                      label: Text('Admin'),
                      backgroundColor: Colors.blue,
                      labelStyle: TextStyle(color: Colors.white),
                    )
                  : const Chip(
                      label: Text('Employee'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
              onTap: () {
                _showEmployeeDetails(employee);
              },
            ),
          );
        },
      ),
    );
  }

  void _showEmployeeDetails(SupabaseUser employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', employee.email),
              if (employee.jobTitle != null)
                _buildDetailRow('Job Title', employee.jobTitle!),
              if (employee.department != null)
                _buildDetailRow('Department', employee.department!),
              if (employee.phone != null)
                _buildDetailRow('Phone', employee.phone!),
              if (employee.nationalId != null)
                _buildDetailRow('National ID', employee.nationalId!),
              if (employee.gender != null)
                _buildDetailRow('Gender', employee.gender!),
              _buildDetailRow(
                'Role',
                employee.isAdmin ? 'Administrator' : 'Employee',
              ),
              _buildDetailRow(
                'Company ID',
                employee.companyId ?? 'Not assigned',
              ),
              _buildDetailRow('Created', _formatDate(employee.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
