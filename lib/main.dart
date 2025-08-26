import 'package:flutter/material.dart';
import 'package:hodorak/screen/splash_screen.dart';

void main() {
  runApp(const Hodorak());
}

class Hodorak extends StatelessWidget {
  const Hodorak({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}

