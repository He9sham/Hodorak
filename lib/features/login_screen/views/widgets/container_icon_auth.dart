import 'package:flutter/material.dart';

class ContainerIconAuth extends StatelessWidget {
  const ContainerIconAuth({super.key, required this.icon});
  final Widget icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
      ),
      child: icon,
    );
  }
}
