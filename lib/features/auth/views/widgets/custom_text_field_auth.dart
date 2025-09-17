import 'package:flutter/material.dart';
import 'package:hodorak/core/widgets/custom_text_form_field.dart';

class CustomTextFieldAuth extends StatelessWidget {
  const CustomTextFieldAuth({
    super.key,
    this.suffixIcon,
    required this.controller,
    required this.hintText,
    required this.validator,
  });
  final Widget? suffixIcon;
  final TextEditingController controller;
  final String hintText;
  final dynamic Function(String?) validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextFormField(
          suffixIcon: suffixIcon,

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: Colors.black),
          ),
          hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          validator: validator,
        ),
      ],
    );
  }
}
