import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/widgets/custom_text_form_field.dart';

class CustomTextFieldAuth extends StatelessWidget {
  const CustomTextFieldAuth({
    super.key,
    this.suffixIcon,
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.maxLines,
    this.isObscureText,
  });

  final Widget? suffixIcon;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final int? maxLines;
  final bool? isObscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        maxLines != null && maxLines! > 1
            ? TextFormField(
                obscureText: isObscureText ?? false,
                controller: controller,
                keyboardType: keyboardType ?? TextInputType.text,
                maxLines: maxLines,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 15,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  suffixIcon: suffixIcon,
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: validator,
              )
            : AppTextFormField(
                suffixIcon: suffixIcon,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                controller: controller,
                keyboardType: keyboardType ?? TextInputType.emailAddress,
                hintText: hintText,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                validator: validator ?? (value) => null,
                onChanged: onChanged,
              ),
      ],
    );
  }
}
