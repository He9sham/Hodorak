import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hodorak/core/theming/styles.dart';

class TextRich extends StatelessWidget {
  const TextRich({super.key, required this.gestureRecognizer});
  final GestureRecognizer gestureRecognizer;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Don’t have an account?',
                style: Styles.textSize13Black600,
              ),
              TextSpan(
                text: '  Sign Up',
                style: Styles.textSize13gree600.copyWith(
                  color: Color(0xff8C9F5F),
                ),
                recognizer: gestureRecognizer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
