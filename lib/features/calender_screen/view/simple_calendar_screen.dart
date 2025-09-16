import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/spacing.dart';

class SimpleCalendarScreen extends StatelessWidget {
  const SimpleCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month, size: 64, color: Colors.grey),
            verticalSpace(16),
            Text(
              'Calendar Feature',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            verticalSpace(8),
            Text(
              'This feature will be available once\nSharedPreferences is properly configured.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
