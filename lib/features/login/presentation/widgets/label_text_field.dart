import 'package:flutter/material.dart';
import 'package:hodorak/core/theming/styles.dart';

class LabelTextField extends StatelessWidget {
  const LabelTextField({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Styles.textbuttom16White.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
