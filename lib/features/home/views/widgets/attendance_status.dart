import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:intl/intl.dart';

class AttendanceStatus extends StatefulWidget {
  const AttendanceStatus({super.key});

  @override
  State<AttendanceStatus> createState() => _AttendanceStatusState();
}

class _AttendanceStatusState extends State<AttendanceStatus> {
  bool isCheckedIn = false;
  DateTime? checkInTime;

  void _handleCheckIn() {
    setState(() {
      isCheckedIn = true;
      checkInTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 343.w,
          height: 242,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color.fromARGB(237, 225, 225, 228),
          ),
        ),
        Positioned(
          left: 20,
          top: 15,
          child: Text(
            'Attendance Status Today',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        Positioned(
          top: 55,
          left: 20,
          child: Container(
            width: 93.w,
            height: 32.h,
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 10, 22, 10)),
              borderRadius: BorderRadius.circular(16),
              color: Color.fromARGB(255, 187, 192, 175),
            ),
            child: Row(
              children: [
                horizontalSpace(3),
                Icon(Icons.calendar_month_outlined),
                horizontalSpace(5),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 55,
          left: 140,
          child: Container(
            height: 32.h,
            width: 63.w,
            decoration: BoxDecoration(
              color: Color(0xffF4E1B1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                horizontalSpace(3),
                Icon(Icons.watch_later_outlined),
                horizontalSpace(5),
                Text(
                  isCheckedIn && checkInTime != null 
                    ? DateFormat('HH:mm').format(checkInTime!)
                    : '00:00',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 110,
          left: 20,
          child: Row(
            children: [
              Image.asset(isCheckedIn ? 'assets/Icon_true.png' : 'assets/Icon_False.png'),
              horizontalSpace(5),
              Text(
                isCheckedIn ? 'You have checked in successfully' : 'You have not checked in yet',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          top: 150,
          child: GestureDetector(
            onTap: isCheckedIn ? null : _handleCheckIn,
            child: Container(
              height: 36.h,
              width: 135.w,
              decoration: BoxDecoration(
                color: isCheckedIn ? Colors.grey : Color(0xff8C9F5F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  horizontalSpace(15),
                  Image.asset('assets/print_fing.png'),
                  horizontalSpace(15),
                  Text(
                    isCheckedIn ? 'Checked-In' : 'Check-In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 150,
          right: 35,
          child: Container(
            height: 36,
            width: 135,
            decoration: BoxDecoration(
              color: Color(0xffF5BA3A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Temporary Leave',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 115,
          child: Container(
            height: 36.h,
            width: 135.w,
            decoration: BoxDecoration(
              color: Color(0xffE93B3B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                horizontalSpace(15),
                Icon(Icons.logout, color: Colors.white),
                horizontalSpace(15),
                Text(
                  'Check-Out',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
