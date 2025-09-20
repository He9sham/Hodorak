import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hodorak/features/home/views/widgets/status_summary_container.dart';

class QuickSummary extends StatelessWidget {
  const QuickSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 245.h,
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Positioned(
          top: 50,
          left: 30,
          child: StatusSummaryContainer(
            title: 'Hours Today',
            subtitle: '00h:00m',
            icon: Icons.watch_later_outlined,
            color: Color(0xffFECF7C),
          ),
        ),
        Positioned(
          top: 50,
          right: 30,
          child: StatusSummaryContainer(
            title: 'Days Present',
            subtitle: '21',
            icon: Icons.check,
            color: Color(0xff7EC26C),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 30,
          child: StatusSummaryContainer(
            title: 'Adherence',
            subtitle: '90%',
            icon: FontAwesomeIcons.paperPlane,
            color: Color(0xffFECF7C).withValues(alpha: 0.6),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 30,
          child: StatusSummaryContainer(
            title: 'Days Adsent',
            subtitle: '2',
            icon: FontAwesomeIcons.x,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
