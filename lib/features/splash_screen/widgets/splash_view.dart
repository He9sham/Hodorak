
import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -120,
          top: -105,
          child: Container(
            height: 360,
            width: 360,
            decoration: BoxDecoration(
              color: Color(0xffF5BA3A),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 350,
          left: 100,
          child: Image.asset('assets/Hodorak.png', height: 150),
        ),
        Positioned(
          bottom: -120,
          right: -100,
          child: Container(
            height: 360,
            width: 360,
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
