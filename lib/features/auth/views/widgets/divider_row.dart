import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DividerRow extends StatelessWidget {
  const DividerRow({super.key, required this.title, required this.spaceRow});
  final String title;
  final double spaceRow;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      width: MediaQuery.sizeOf(context).width,
      child: Stack(
        children: [
          Positioned(
            child: Divider(
              endIndent: 20,
              indent: 235,
              thickness: 1,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            right: 122.w,
            bottom: 13.h,
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xff929292),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            child: Divider(
              endIndent: spaceRow,
              indent: 20,
              thickness: 1,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
