import 'package:flutter/material.dart';
import 'package:hodorak/core/providers/auth_provider.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.onPressed, required this.authState});
  final void Function() onPressed;
  final AuthState authState;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: onPressed,
            child: authState.isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),

                      Text('Logging in...'),
                    ],
                  )
                : const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
