import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hodorak/core/theming/colors_manger.dart';

abstract class Styles {
  static TextStyle textonbording23 = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 23.sp,
    fontFamily: GoogleFonts.cairo().fontFamily,
    color: ColorsManager.blackText,
  );

  static TextStyle textonbording13 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13.sp,
    fontFamily: GoogleFonts.cairo().fontFamily,
    color: ColorsManager.blackText,
  );

  static TextStyle textappBar = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 19.sp,
    fontFamily: GoogleFonts.cairo().fontFamily,
    color: ColorsManager.blackText,
  );

  static TextStyle textSize13Black600 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13.sp,
    fontFamily: GoogleFonts.cairo().fontFamily,
    color: ColorsManager.blackText,
  );

  static TextStyle textSize13gree600 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13.sp,
    fontFamily: GoogleFonts.roboto().fontFamily,
    color: Colors.green,
  );

  static TextStyle textbuttom16White = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16.sp,
    fontFamily: GoogleFonts.cairo().fontFamily,
    color: Colors.white,
  );

  static TextStyle textRowNavigate16gray = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
    fontFamily: GoogleFonts.cairo().fontFamily,
    color: const Color(0xffA4ACAD),
  );
  static TextStyle textRowNavigate16green = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
    fontFamily: GoogleFonts.cairo().fontFamily,
    color: Colors.green,
  );
}
