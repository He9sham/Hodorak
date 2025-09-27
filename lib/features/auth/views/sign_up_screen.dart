import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/signup_notifier.dart';
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
  final _nameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final TapGestureRecognizer _signInRecognizer;
  bool _obscurePassword = true;
  String? _selectedGender;

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    await ref
        .read(signUpNotifierProvider.notifier)
        .signUpEmployee(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          jobTitle: _jobTitleController.text.trim(),
          department: _departmentController.text.trim(),
          phone: _phoneController.text.trim(),
          nationalId: _nationalIdController.text.trim(),
          gender: _selectedGender ?? '',
        );

    final latest = ref.read(signUpNotifierProvider);
    if (latest.error != null) {
      if (!mounted) return;

      String errorMsg = latest.error!;
      Color backgroundColor = Colors.red;
      SnackBarAction? action;

      if (latest.error!.contains('No internet connection') ||
          latest.error!.contains('Network error') ||
          latest.error!.contains('HTTP error')) {
        errorMsg =
            'No internet connection. Please check your network settings and try again.';
        backgroundColor = Colors.orange;
        action = SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => _onSubmit(),
        );
      } else if (latest.error!.contains('Only admins can create accounts.')) {
        errorMsg = 'Only administrators can create new accounts.';
        backgroundColor = Colors.red;
      } else if (latest.error!.contains('Access denied')) {
        errorMsg =
            'Access denied. Only administrators can create employee accounts.';
        backgroundColor = Colors.red;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 4),
          action: action,
        ),
      );
    } else if (latest.message != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(latest.message!),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    _signInRecognizer = TapGestureRecognizer()
      ..onTap = () {
        context.pushReplacementNamed(Routes.loginScreen);
      };
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _jobTitleController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _signInRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpNotifierProvider);
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
                  verticalSpace(30),
                  // Logo/Title
                  Text(
                    'Sign Up',
                    style: Styles.textSize13Black600.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  verticalSpace(48),

                  // Name Field
                  LabelTextField(title: 'Full Name'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _nameController,
                    hintText: 'Enter Full Name',
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter full name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),
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
                  // Job Title Field
                  LabelTextField(title: 'Job Title'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _jobTitleController,
                    hintText: 'Enter Job Title',
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter job title';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),
                  // Department Field
                  LabelTextField(title: 'Department'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _departmentController,
                    hintText: 'Enter Department',
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter department';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),
                  // Phone Number Field
                  LabelTextField(title: 'Phone Number'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _phoneController,
                    hintText: 'Enter Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.length < 10) {
                        return 'Phone number must be at least 10 digits';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),
                  // National ID Field
                  LabelTextField(title: 'National ID'),
                  verticalSpace(8),
                  CustomTextFieldAuth(
                    controller: _nationalIdController,
                    hintText: 'Enter National ID',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter national ID';
                      }
                      if (value.length < 8) {
                        return 'National ID must be at least 8 digits';
                      }
                      return null;
                    },
                  ),

                  verticalSpace(16),
                  // Gender Field
                  LabelTextField(title: 'Gender'),
                  verticalSpace(8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: InputDecoration(
                      hintText: 'Select Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 15,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: ['Male', 'Female'].map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select gender';
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

                  if (signUpState.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            signUpState.error!.contains(
                                  'No internet connection',
                                ) ||
                                signUpState.error!.contains('Network error') ||
                                signUpState.error!.contains('HTTP error')
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              signUpState.error!.contains(
                                    'No internet connection',
                                  ) ||
                                  signUpState.error!.contains(
                                    'Network error',
                                  ) ||
                                  signUpState.error!.contains('HTTP error')
                              ? Colors.orange
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            signUpState.error!.contains(
                                      'No internet connection',
                                    ) ||
                                    signUpState.error!.contains(
                                      'Network error',
                                    ) ||
                                    signUpState.error!.contains('HTTP error')
                                ? Icons.wifi_off
                                : Icons.error,
                            color:
                                signUpState.error!.contains(
                                      'No internet connection',
                                    ) ||
                                    signUpState.error!.contains(
                                      'Network error',
                                    ) ||
                                    signUpState.error!.contains('HTTP error')
                                ? Colors.orange
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              signUpState.error!,
                              style: TextStyle(
                                color:
                                    signUpState.error!.contains(
                                          'No internet connection',
                                        ) ||
                                        signUpState.error!.contains(
                                          'Network error',
                                        ) ||
                                        signUpState.error!.contains(
                                          'HTTP error',
                                        )
                                    ? Colors.orange.shade800
                                    : Colors.red.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (signUpState.message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        signUpState.message!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),

                  // Login Button
                  LoginButton(
                    title: 'Sign Up',
                    onPressed: _onSubmit,
                    isLoading: signUpState.isLoading,
                  ),
                  verticalSpace(24),
                  DividerRow(spaceRow: 250, title: 'Or Register with'),
                  verticalSpace(32),
                  // row auth for social media
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContainerIconAuth(icon: Icon(Icons.apple)),
                      horizontalSpace(10),
                      ContainerIconAuth(icon: Icon(Icons.facebook)),
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
