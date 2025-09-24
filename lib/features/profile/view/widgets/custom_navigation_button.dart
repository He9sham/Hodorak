import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hodorak/core/helper/spacing.dart';

class CustomNavigationButton extends StatelessWidget {
  const CustomNavigationButton({
    super.key,
    required this.title,
    required this.icons,
    this.iconSize,
  });
  final String title;
  final IconData icons;
  final double? iconSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: Color(0xff8C9F5F),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Row(
        children: [
          horizontalSpace(10),
          Icon(icons, color: Colors.white),
          horizontalSpace(15),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          horizontalSpace(iconSize ?? 200),
          Icon(
            FontAwesomeIcons.arrowRightFromBracket,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}
