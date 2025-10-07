import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/widgets/custom_text_form_field.dart';

class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.label,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
    this.maxLines,
    this.isObscureText,
    this.errorText,
  });

  final TextEditingController controller;
  final String hintText;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final int? maxLines;
  final bool? isObscureText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),

        // Text Field
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
                    vertical: 20.h,
                    horizontal: 15.w,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  suffixIcon: suffixIcon,
                  filled: true,
                  fillColor: Colors.grey[100],
                  errorText: errorText,
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
                keyboardType: keyboardType ?? TextInputType.text,
                hintText: hintText,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20.h,
                  horizontal: 15.w,
                ),
                validator: validator ?? (value) => null,
                onChanged: onChanged,
                isObscureText: isObscureText,
              ),
      ],
    );
  }
}
