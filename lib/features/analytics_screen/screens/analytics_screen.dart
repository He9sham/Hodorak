import 'package:flutter/material.dart';
import 'package:hodorak/features/analytics_screen/widgets/analytics_dashboard.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Analytics',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff8C9F5F),
        foregroundColor: Colors.white,
      ),
      body: const AnalyticsDashboard(),
    );
  }
}
