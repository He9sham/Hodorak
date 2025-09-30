import 'package:flutter/material.dart';

class CustomButtonAuth extends StatelessWidget {
  const CustomButtonAuth({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.title,
  });
  final void Function() onPressed;
  final bool isLoading;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: onPressed,
            child: isLoading
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

                      Text('  Logging in...'),
                    ],
                  )
                : Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
