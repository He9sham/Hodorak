import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/auth_provider.dart';
import 'package:hodorak/core/theming/styles.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/auth/views/widgets/container_icon_auth.dart';
import 'package:hodorak/features/auth/views/widgets/custom_text_field_auth.dart';
import 'package:hodorak/features/auth/views/widgets/divider_row.dart';
import 'package:hodorak/features/auth/views/widgets/label_text_field.dart';
import 'package:hodorak/features/auth/views/widgets/login_button.dart';
import 'package:hodorak/features/auth/views/widgets/text_rich.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final TapGestureRecognizer _signInRecognizer;
  bool _obscurePassword = true;
  @override
  void initState() {
    _signInRecognizer = TapGestureRecognizer()
      ..onTap = () {
        context.pushReplacementNamed(Routes.loginScreen);
      };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  verticalSpace(50),
                  // Logo/Title
                  Text(
                    'Sign Up',
                    style: Styles.textSize13Black600.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
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
                  verticalSpace(16),
                  LabelTextField(title: 'Confirm Password'),
                  verticalSpace(8),
                  // Password Field
                  CustomTextFieldAuth(
                    hintText: 'Enter Confirm Password',
                    controller: _confirmPasswordController,
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
                  verticalSpace(48),

                  // Error Message
                  // if (authState.error != null)
                  //   CustomErrorMessage(authState: authState),

                  // Login Button
                  LoginButton(
                    onPressed: () {
                      // authState.isLoading ? null : login();
                    },
                    authState: authState,
                  ),
                  verticalSpace(24),
                  DividerRow(spaceRow: 250, title: 'Or Register with'),
                  verticalSpace(32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContainerIconAuth(icon: Icon(Icons.apple)),
                      horizontalSpace(10),
                      ContainerIconAuth(icon: Icon(FontAwesomeIcons.facebook)),
                      horizontalSpace(10),
                      ContainerIconAuth(icon: Icon(FontAwesomeIcons.google)),
                    ],
                  ),
                  verticalSpace(30),
                  // when user do not have any account
                  TextRich(
                    gestureRecognizer: _signInRecognizer,
                    title: 'Already have an account?',
                    subtitle: ' Sign In',
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
