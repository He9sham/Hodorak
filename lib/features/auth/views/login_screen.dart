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
import 'package:hodorak/features/auth/views/widgets/custom_error_message.dart';
import 'package:hodorak/features/auth/views/widgets/custom_text_field_auth.dart';
import 'package:hodorak/features/auth/views/widgets/divider_row.dart';
import 'package:hodorak/features/auth/views/widgets/label_text_field.dart';
import 'package:hodorak/features/auth/views/widgets/login_button.dart';
import 'package:hodorak/features/auth/views/widgets/text_rich.dart';
import 'package:hodorak/features/main_navigation/simple_main_navigation_screen.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _signUpRecognizer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _signUpRecognizer = TapGestureRecognizer()
      ..onTap = () {
        context.pushReplacementNamed(Routes.signupScreen);
      };
  }

  /// Login function to login to the app
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_emailController.text, _passwordController.text);

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              SimpleMainNavigationScreen(odooService: authState.odooService!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
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
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'Forget Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8C9F5F),
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(24),

                  // Error Message
                  if (authState.error != null)
                    CustomErrorMessage(authState: authState),

                  // Login Button
                  LoginButton(
                    onPressed: () {
                      authState.isLoading ? null : login();
                    },
                    authState: authState,
                  ),
                  verticalSpace(24),
                  DividerRow(title: 'Or Log in with', spaceRow: 235,),
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
                    subtitle: '  Sign Up',
                    title: 'Don’t have an account?',
                    gestureRecognizer: _signUpRecognizer,
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
