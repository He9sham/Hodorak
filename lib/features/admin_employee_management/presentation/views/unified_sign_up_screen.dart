import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/theming/styles.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/admin_employee_management/presentation/viewmodels/create_employees_view_models.dart';
import 'package:hodorak/features/admin_employee_management/presentation/widgets/sign_up_error_widget.dart';
import 'package:hodorak/features/admin_employee_management/presentation/widgets/sign_up_gender_dropdown.dart';
import 'package:hodorak/features/admin_employee_management/presentation/widgets/sign_up_success_widget.dart';
import 'package:hodorak/features/admin_employee_management/presentation/widgets/sign_up_text_field.dart';
import 'package:hodorak/features/login/presentation/widgets/login_button.dart';
import 'package:hodorak/features/login/presentation/widgets/text_rich.dart';

// Constants
class _Constants {
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const EdgeInsets snackBarMargin = EdgeInsets.all(16);
  static const BorderRadius snackBarBorderRadius = BorderRadius.all(
    Radius.circular(8),
  );
  static const double titleFontSize = 32.0;
  static const double padding = 24.0;
  static const double verticalSpacing = 30.0;
  static const double formSpacing = 16.0;
  static const double buttonSpacing = 30.0;
}

class UnifiedSignUpScreen extends ConsumerStatefulWidget {
  final bool isEmployeeCreation;
  final VoidCallback? onEmployeeCreated;

  const UnifiedSignUpScreen({
    super.key,
    this.isEmployeeCreation = false,
    this.onEmployeeCreated,
  });

  @override
  ConsumerState<UnifiedSignUpScreen> createState() =>
      _UnifiedSignUpScreenState();
}

class _UnifiedSignUpScreenState extends ConsumerState<UnifiedSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TapGestureRecognizer _signInRecognizer;

  @override
  void initState() {
    super.initState();
    _initializeGestureRecognizer();
  }

  @override
  void dispose() {
    _signInRecognizer.dispose();
    super.dispose();
  }

  void _initializeGestureRecognizer() {
    _signInRecognizer = TapGestureRecognizer()
      ..onTap = () {
        if (widget.isEmployeeCreation) {
          Navigator.of(context).pop();
        } else {
          context.pushReplacementNamed(Routes.loginScreen);
        }
      };
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() != true) return;

    try {
      if (widget.isEmployeeCreation) {
        await _createEmployee();
      } else {
        await _signUpUser();
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _createEmployee() async {
    final signUpViewModel = ref.read(signUpViewModelProvider);

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
      _showSuccessSnackBar('Employee created successfully!');
      widget.onEmployeeCreated?.call();
      Navigator.of(context).pop();
    }
  }

  Future<void> _signUpUser() async {
    final signUpViewModel = ref.read(signUpViewModelProvider);
    await signUpViewModel.signUp();

    if (signUpViewModel.state.isSuccess && mounted) {
      _showSuccessSnackBar('Account created successfully!');
      signUpViewModel.clearSuccessState();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: _Constants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        margin: _Constants.snackBarMargin,
        shape: RoundedRectangleBorder(
          borderRadius: _Constants.snackBarBorderRadius,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: _Constants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        margin: _Constants.snackBarMargin,
        shape: RoundedRectangleBorder(
          borderRadius: _Constants.snackBarBorderRadius,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUpViewModel = ref.watch(signUpViewModelProvider);
    final signUpState = signUpViewModel.state;
    final authState = ref.watch(supabaseAuthProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(_Constants.padding.w),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!widget.isEmployeeCreation)
                      verticalSpace(_Constants.verticalSpacing),
                    _buildTitle(),
                    verticalSpace(48),
                    ..._buildFormFields(signUpViewModel, signUpState),
                    verticalSpace(32),
                    ..._buildStatusWidgets(signUpState),
                    _buildSubmitButton(signUpState, authState),
                    verticalSpace(_Constants.buttonSpacing),
                    if (!widget.isEmployeeCreation) _buildSignInLink(),
                    if (!widget.isEmployeeCreation)
                      verticalSpace(_Constants.verticalSpacing),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (!widget.isEmployeeCreation) return null;

    return AppBar(
      title: const Text(
        'Create Employee',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.isEmployeeCreation ? 'Create New Employee' : 'Sign Up',
      style: Styles.textSize13Black600.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: _Constants.titleFontSize.sp,
      ),
    );
  }

  List<Widget> _buildFormFields(SignUpViewModel viewModel, SignUpState state) {
    return [
      _buildNameField(viewModel, state),
      verticalSpace(_Constants.formSpacing),
      _buildEmailField(viewModel, state),
      verticalSpace(_Constants.formSpacing),
      _buildJobTitleField(viewModel, state),
      verticalSpace(_Constants.formSpacing),
      _buildDepartmentField(viewModel, state),
      verticalSpace(_Constants.formSpacing),
      _buildPhoneField(viewModel, state),
      verticalSpace(_Constants.formSpacing),
      _buildNationalIdField(viewModel, state),
      verticalSpace(_Constants.formSpacing),
      _buildGenderField(viewModel, state),
      verticalSpace(_Constants.formSpacing),
      _buildPasswordField(viewModel, state),
      verticalSpace(_Constants.formSpacing),
      if (!widget.isEmployeeCreation) ...[
        _buildConfirmPasswordField(viewModel, state),
        verticalSpace(_Constants.formSpacing),
      ],
    ];
  }

  Widget _buildNameField(SignUpViewModel viewModel, SignUpState state) {
    return SignUpTextField(
      controller: viewModel.nameController,
      hintText: 'Enter Full Name',
      label: 'Full Name',
      validator: (value) => _validateRequiredField(value, 'full name'),
      onChanged: viewModel.updateName,
    );
  }

  Widget _buildEmailField(SignUpViewModel viewModel, SignUpState state) {
    return SignUpTextField(
      controller: viewModel.emailController,
      hintText: 'Enter Your Email',
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: (value) => _validateEmail(value),
      onChanged: viewModel.updateEmail,
    );
  }

  Widget _buildJobTitleField(SignUpViewModel viewModel, SignUpState state) {
    return SignUpTextField(
      controller: viewModel.jobTitleController,
      hintText: 'Enter Job Title',
      label: 'Job Title',
      validator: (value) => _validateRequiredField(value, 'job title'),
      onChanged: viewModel.updateJobTitle,
    );
  }

  Widget _buildDepartmentField(SignUpViewModel viewModel, SignUpState state) {
    return SignUpTextField(
      controller: viewModel.departmentController,
      hintText: 'Enter Department',
      label: 'Department',
      validator: (value) => _validateRequiredField(value, 'department'),
      onChanged: viewModel.updateDepartment,
    );
  }

  Widget _buildPhoneField(SignUpViewModel viewModel, SignUpState state) {
    return SignUpTextField(
      controller: viewModel.phoneController,
      hintText: 'Enter Phone Number',
      label: 'Phone Number',
      keyboardType: TextInputType.phone,
      validator: (value) => _validateRequiredField(value, 'phone number'),
      onChanged: viewModel.updatePhone,
    );
  }

  Widget _buildNationalIdField(SignUpViewModel viewModel, SignUpState state) {
    return SignUpTextField(
      controller: viewModel.nationalIdController,
      hintText: 'Enter National ID',
      label: 'National ID',
      keyboardType: TextInputType.number,
      validator: (value) => _validateRequiredField(value, 'national ID'),
      onChanged: viewModel.updateNationalId,
    );
  }

  Widget _buildGenderField(SignUpViewModel viewModel, SignUpState state) {
    return SignUpGenderDropdown(
      selectedGender: state.gender.isEmpty ? null : state.gender,
      onChanged: viewModel.updateGender,
      errorText: widget.isEmployeeCreation
          ? null
          : state.validationErrors?.genderError,
    );
  }

  Widget _buildPasswordField(SignUpViewModel viewModel, SignUpState state) {
    return SignUpTextField(
      controller: viewModel.passwordController,
      hintText: 'Enter your password',
      label: 'Password',
      isObscureText: state.obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          state.obscurePassword ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: viewModel.togglePasswordVisibility,
      ),
      validator: (value) => _validatePassword(value),
      onChanged: viewModel.updatePassword,
    );
  }

  Widget _buildConfirmPasswordField(
    SignUpViewModel viewModel,
    SignUpState state,
  ) {
    return SignUpTextField(
      controller: viewModel.confirmPasswordController,
      hintText: 'Enter Confirm Password',
      label: 'Confirm Password',
      isObscureText: state.obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          state.obscurePassword ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: viewModel.togglePasswordVisibility,
      ),
      validator: (value) => state.validationErrors?.confirmPasswordError,
      onChanged: viewModel.updateConfirmPassword,
    );
  }

  List<Widget> _buildStatusWidgets(SignUpState state) {
    final widgets = <Widget>[];

    if (state.error != null) {
      widgets.addAll([
        SignUpErrorWidget(error: state.error!),
        verticalSpace(_Constants.formSpacing),
      ]);
    }

    if (!widget.isEmployeeCreation && state.isSuccess) {
      widgets.addAll([
        const SignUpSuccessWidget(),
        verticalSpace(_Constants.formSpacing),
      ]);
    }

    return widgets;
  }

  Widget _buildSubmitButton(
    SignUpState signUpState,
    SupabaseAuthState authState,
  ) {
    return CustomButtonAuth(
      title: widget.isEmployeeCreation ? 'Create Employee' : 'Sign Up',
      onPressed: _handleSubmit,
      isLoading: widget.isEmployeeCreation
          ? authState.isLoading
          : signUpState.isLoading,
    );
  }

  Widget _buildSignInLink() {
    return TextRich(
      gestureRecognizer: _signInRecognizer,
      title: 'Account created successfully?',
      subtitle: '  Sign In',
    );
  }

  // Validation helper methods
  String? _validateRequiredField(String? value, String fieldName) {
    if (widget.isEmployeeCreation) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter $fieldName';
      }
      return null;
    }
    return null; // Regular signup uses view model validation
  }

  String? _validateEmail(String? value) {
    if (widget.isEmployeeCreation) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter email';
      }
      if (!value.contains('@')) {
        return 'Please enter a valid email';
      }
      return null;
    }
    return null; // Regular signup uses view model validation
  }

  String? _validatePassword(String? value) {
    if (widget.isEmployeeCreation) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter password';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
      return null;
    }
    return null; // Regular signup uses view model validation
  }
}
