import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hodorak/core/models/monthly_attendance_summary.dart';
import 'package:hodorak/features/home/views/widgets/status_summary_container.dart';

class QuickSummary extends StatelessWidget {
  final MonthlyAttendanceSummary? monthlySummary;
  final int? currentUserId;

  const QuickSummary({super.key, this.monthlySummary, this.currentUserId});

  String _formatHours(Duration? duration) {
    if (duration == null) return '00h:00m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}h:${minutes.toString().padLeft(2, '0')}m';
  }

  String _getTotalHoursThisMonth() {
    if (monthlySummary == null) return '00h:00m';
    return _formatHours(monthlySummary!.totalWorkingHours);
  }

  String _getDaysPresent() {
    if (monthlySummary == null) return '0';
    return monthlySummary!.daysPresent.toString();
  }

  String _getDaysAbsent() {
    if (monthlySummary == null) return '0';
    return monthlySummary!.daysAbsent.toString();
  }

  String _getAdherence() {
    if (monthlySummary == null) return '0%';
    return '${monthlySummary!.attendancePercentage.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250.h, // Slightly increased to accommodate taller containers
          width: 343.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color.fromARGB(237, 225, 225, 228),
          ),
        ),
        Positioned(
          top: 15,
          left: 20,
          child: Text(
            'Quick Summary',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Positioned(
          top: 50,
          left: 30,
          child: StatusSummaryContainer(
            title: 'Hours This Month',
            subtitle: _getTotalHoursThisMonth(),
            icon: Icons.watch_later_outlined,
            color: Color(0xffFECF7C),
          ),
        ),
        Positioned(
          top: 50,
          right: 30,
          child: StatusSummaryContainer(
            title: 'Days Present',
            subtitle: _getDaysPresent(),
            icon: Icons.check,
            color: Color(0xff7EC26C),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 30,
          child: StatusSummaryContainer(
            title: 'Adherence',
            subtitle: _getAdherence(),
            icon: FontAwesomeIcons.paperPlane,
            color: Color(0xffFECF7C).withValues(alpha: 0.6),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 30,
          child: StatusSummaryContainer(
            title: 'Days Absent',
            subtitle: _getDaysAbsent(),
            icon: FontAwesomeIcons.x,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
