import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hodorak/core/theming/styles.dart';

class TextRich extends StatelessWidget {
  const TextRich({
    super.key,
    this.gestureRecognizer,
    required this.title,
    required this.subtitle,
  });
  final GestureRecognizer? gestureRecognizer;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: title, style: Styles.textSize13Black600),
              TextSpan(
                text: subtitle,
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
