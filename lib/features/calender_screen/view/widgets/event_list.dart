import 'package:flutter/material.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/features/calender_screen/view/widgets/attendance_card.dart';

class EventList extends StatelessWidget {
  final List<DailyAttendanceSummary> events;
  final DateTime day;

  const EventList({super.key, required this.events, required this.day});

  @override
  Widget build(BuildContext context) {
    print(
      'EventList: Building event list for $day - Found ${events.length} events',
    );

    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No attendance data for you on this day',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final summary = events[index];
        print(
          'EventList: Building card for ${summary.date} - ${summary.presentEmployees}/${summary.totalEmployees} present',
        );
        return AttendanceCard(summary: summary);
      },
    );
  }
}
