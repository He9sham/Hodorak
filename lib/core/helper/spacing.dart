import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

SizedBox verticalSpace(double height) => SizedBox(height: height.h);

SizedBox horizontalSpace(double width) => SizedBox(width: width.w);

double sizeOfWidth(double width, BuildContext context) {
  return MediaQuery.sizeOf(context).width * width;
}

double sizeOfHeight(double height, BuildContext context) {
  return MediaQuery.sizeOf(context).height * height;
}
