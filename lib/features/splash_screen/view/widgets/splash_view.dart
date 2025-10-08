import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -120.w,
          top: -105.h,
          child: Container(
            height: 300.h,
            width: 300.w,
            decoration: BoxDecoration(
              color: Color(0xffF5BA3A),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 350.h,
          left: 100.w,
          child: Image.asset('assets/Hodorak.png'),
        ),
        Positioned(
          bottom: -120.h,
          right: -100.w,
          child: Container(
            height: 300.h,
            width: 300.w,
            decoration: BoxDecoration(
              color: Color(0xff8C9F5F),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
