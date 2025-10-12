import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/theming/styles.dart';

class CustomContainerTextView extends StatelessWidget {
  const CustomContainerTextView({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title, subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: sizeOfHeight(0.55, context)),
          Text(
            title,
            style: Styles.textonbording23.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpace(20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Styles.textonbording13.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
