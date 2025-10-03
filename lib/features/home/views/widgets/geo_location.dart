import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

class GeoLocation extends StatelessWidget {
  const GeoLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 260.h,
          width: 343.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color.fromARGB(237, 225, 225, 228),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Text(
            'Geo Location',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),

        Positioned(
          top: 50,
          right: 30,
          child: Container(
            width: 300.w,
            height: 160.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Image.asset('assets/Frame_location.png'),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Row(
            children: [
              Image.asset('assets/Icon_true.png'),
              horizontalSpace(8),
              Text(
                'You are inside the allowed zone',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
