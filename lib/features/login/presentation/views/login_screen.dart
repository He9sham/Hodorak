import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/supabase_company.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/theming/styles.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/login/domain/entities/login_result_entity.dart';
import 'package:hodorak/features/login/presentation/widgets/custom_text_field_auth.dart';
import 'package:hodorak/features/login/presentation/widgets/label_text_field.dart';
import 'package:hodorak/features/login/presentation/widgets/login_button.dart';
import 'package:hodorak/features/login/presentation/widgets/text_rich.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  late final TapGestureRecognizer _signUpRecognizer;
  late final TapGestureRecognizer _createCompanyRecognizer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signUpRecognizer.dispose();
    _createCompanyRecognizer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _signUpRecognizer = TapGestureRecognizer()
      ..onTap = () {
        context.pushReplacementNamed(Routes.signupScreen);
      };
    _createCompanyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _navigateToCompanyCreation();
      };
  }

  /// Navigate to company creation screen
  Future<void> _navigateToCompanyCreation() async {
    final result = await context.pushNamed(Routes.companyCreationScreen);

    if (result != null && result is SupabaseCompany) {
      // Company was created successfully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Company "${result.name}" created successfully! You can now sign up.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Login using the existing auth provider
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(supabaseAuthProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());

      if (mounted) {
        // Wait a moment for the auth state to update
        await Future.delayed(const Duration(milliseconds: 100));
        final authState = ref.read(supabaseAuthProvider);

        if (authState.isAuthenticated) {
          final route = authState.isAdmin
              ? Routes.adminHomeScreen
              : Routes.userHomeScreen;
          context.pushReplacementNamed(route);
        } else {
          _showErrorSnackBar(
            context,
            'Login failed. Please try again.',
            LoginStatus.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        LoginStatus status = LoginStatus.error;

        if (errorMsg.contains('Invalid email or password')) {
          status = LoginStatus.invalidCredentials;
        } else if (errorMsg.contains('Email not confirmed')) {
          status = LoginStatus.emailNotConfirmed;
        } else if (errorMsg.contains('Network error') ||
            errorMsg.contains('No internet connection')) {
          status = LoginStatus.networkError;
        }

        _showErrorSnackBar(context, errorMsg, status);
      }
    }
  }

  void _showErrorSnackBar(
    BuildContext context,
    String errorMessage,
    LoginStatus status,
  ) {
    Color backgroundColor = Colors.red;
    SnackBarAction? action;

    switch (status) {
      case LoginStatus.networkError:
        backgroundColor = Colors.orange;
        action = SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => login(),
        );
        break;
      case LoginStatus.emailNotConfirmed:
        backgroundColor = Colors.blue;
        break;
      case LoginStatus.invalidCredentials:
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: action,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(supabaseAuthProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    verticalSpace(50),
                    // Logo/Title
                    Text(
                      'Sign in',
                      style: Styles.textSize13Black600.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.sp,
                      ),
                    ),
                    verticalSpace(48),
                    LabelTextField(title: 'Email'),
                    verticalSpace(8),
                    // Email Field
                    CustomTextFieldAuth(
                      controller: _emailController,
                      hintText: 'Enter Your Email',
                      validator: (value) {
                        value = value!.trim();
                        if (value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    verticalSpace(16),
                    LabelTextField(title: 'Password'),
                    verticalSpace(8),
                    // Password Field
                    CustomTextFieldAuth(
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 3) {
                          return 'Password must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    verticalSpace(20),
                    // Text under Forgot Password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'First time using the app? Create your company to get started.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    verticalSpace(20),

                    // Company Creation Toggle
                    TextRich(
                      title: 'Need to create a company?',
                      subtitle: ' Create Company',
                      gestureRecognizer: _createCompanyRecognizer,
                    ),

                    verticalSpace(40),

                    // Login Button
                    CustomButtonAuth(
                      title: 'Sign in',
                      onPressed: () async {
                        authState.isLoading ? null : await login();
                      },
                      isLoading: authState.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
