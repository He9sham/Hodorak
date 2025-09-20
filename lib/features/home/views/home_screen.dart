import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/features/home/views/widgets/attendance_status.dart';
import 'package:hodorak/features/home/views/widgets/geo_location.dart';
import 'package:hodorak/features/home/views/widgets/quick_summary.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Hodorak',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff8C9F5F),
        actions: [
          Icon(Icons.notifications_active_outlined, size: 30),
          horizontalSpace(8),
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Image.asset("assets/unsplash_CHqrLlwebdM.png", height: 33),
          ),
          horizontalSpace(10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              verticalSpace(17),
              AttendanceStatus(),
              verticalSpace(16),
              GeoLocation(),
              verticalSpace(16),
              QuickSummary(),
              verticalSpace(16),
            ],
          ),
        ),
      ),
    );
  }
}
