import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/theming/styles.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/auth/sign_up/presentation/viewmodels/sign_up_viewmodel.dart';
import 'package:hodorak/features/auth/sign_up/presentation/widgets/sign_up_error_widget.dart';
import 'package:hodorak/features/auth/sign_up/presentation/widgets/sign_up_gender_dropdown.dart';
import 'package:hodorak/features/auth/sign_up/presentation/widgets/sign_up_success_widget.dart';
import 'package:hodorak/features/auth/sign_up/presentation/widgets/sign_up_text_field.dart';
import 'package:hodorak/features/auth/views/widgets/login_button.dart';
import 'package:hodorak/features/auth/views/widgets/text_rich.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TapGestureRecognizer _signInRecognizer;

  @override
  void initState() {
    super.initState();
    _signInRecognizer = TapGestureRecognizer()
      ..onTap = () {
        context.pushReplacementNamed(Routes.loginScreen);
      };
  }

  @override
  void dispose() {
    _signInRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpViewModel = ref.watch(signUpViewModelProvider);
    final signUpState = signUpViewModel.state;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  verticalSpace(30),

                  // Title
                  Text(
                    'Sign Up',
                    style: Styles.textSize13Black600.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.sp,
                    ),
                  ),
                  verticalSpace(48),

                  // Name Field
                  SignUpTextField(
                    controller: signUpViewModel.nameController,
                    hintText: 'Enter Full Name',
                    label: 'Full Name',
                    validator: (value) {
                      return signUpState.validationErrors?.nameError;
                    },
                    onChanged: signUpViewModel.updateName,
                  ),
                  verticalSpace(16),

                  // Email Field
                  SignUpTextField(
                    controller: signUpViewModel.emailController,
                    hintText: 'Enter Your Email',
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      return signUpState.validationErrors?.emailError;
                    },
                    onChanged: signUpViewModel.updateEmail,
                  ),
                  verticalSpace(16),

                  // Job Title Field
                  SignUpTextField(
                    controller: signUpViewModel.jobTitleController,
                    hintText: 'Enter Job Title',
                    label: 'Job Title',
                    validator: (value) {
                      return signUpState.validationErrors?.jobTitleError;
                    },
                    onChanged: signUpViewModel.updateJobTitle,
                  ),
                  verticalSpace(16),

                  // Department Field
                  SignUpTextField(
                    controller: signUpViewModel.departmentController,
                    hintText: 'Enter Department',
                    label: 'Department',
                    validator: (value) {
                      return signUpState.validationErrors?.departmentError;
                    },
                    onChanged: signUpViewModel.updateDepartment,
                  ),
                  verticalSpace(16),

                  // Phone Number Field
                  SignUpTextField(
                    controller: signUpViewModel.phoneController,
                    hintText: 'Enter Phone Number',
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      return signUpState.validationErrors?.phoneError;
                    },
                    onChanged: signUpViewModel.updatePhone,
                  ),
                  verticalSpace(16),

                  // National ID Field
                  SignUpTextField(
                    controller: signUpViewModel.nationalIdController,
                    hintText: 'Enter National ID',
                    label: 'National ID',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      return signUpState.validationErrors?.nationalIdError;
                    },
                    onChanged: signUpViewModel.updateNationalId,
                  ),
                  verticalSpace(16),

                  // Gender Field
                  SignUpGenderDropdown(
                    selectedGender: signUpState.gender.isEmpty
                        ? null
                        : signUpState.gender,
                    onChanged: signUpViewModel.updateGender,
                    errorText: signUpState.validationErrors?.genderError,
                  ),
                  verticalSpace(16),

                  // Password Field
                  SignUpTextField(
                    controller: signUpViewModel.passwordController,
                    hintText: 'Enter your password',
                    label: 'Password',
                    isObscureText: signUpState.obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        signUpState.obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: signUpViewModel.togglePasswordVisibility,
                    ),
                    validator: (value) {
                      return signUpState.validationErrors?.passwordError;
                    },
                    onChanged: signUpViewModel.updatePassword,
                  ),
                  verticalSpace(16),

                  // Confirm Password Field
                  SignUpTextField(
                    controller: signUpViewModel.confirmPasswordController,
                    hintText: 'Enter Confirm Password',
                    label: 'Confirm Password',
                    isObscureText: signUpState.obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        signUpState.obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: signUpViewModel.togglePasswordVisibility,
                    ),
                    validator: (value) {
                      return signUpState.validationErrors?.confirmPasswordError;
                    },
                    onChanged: signUpViewModel.updateConfirmPassword,
                  ),
                  verticalSpace(48),

                  // Error Widget
                  if (signUpState.error != null) ...[
                    SignUpErrorWidget(error: signUpState.error!),
                    verticalSpace(16),
                  ],

                  // Success Widget
                  if (signUpState.isSuccess) ...[
                    const SignUpSuccessWidget(),
                    verticalSpace(16),
                  ],

                  // Sign Up Button
                  CustomButtonAuth(
                    title: 'Sign Up',
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        await signUpViewModel.signUp();

                        // Show snackbar on success
                        if (signUpViewModel.state.isSuccess) {
                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Account created successfully!'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                            // Clear success state after showing snackbar
                            signUpViewModel.clearSuccessState();
                          }
                        }
                      }
                    },
                    isLoading: signUpState.isLoading,
                  ),
                  verticalSpace(30),

                  // Sign In Link
                  TextRich(
                    gestureRecognizer: _signInRecognizer,
                    title: 'Account created successfully?',
                    subtitle: '  Sign In',
                  ),
                  verticalSpace(30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
