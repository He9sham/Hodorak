import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/providers/user_profile_provider.dart';

class ShowDetailsWidget extends ConsumerWidget {
  const ShowDetailsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(userProfileProvider);

    return Stack(
      children: [
        Container(
          height: 316.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xffF5BA3A),
                Color(0xff8C9F5F), // You can adjust this color
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        Positioned(
          top: 70.h,
          left: 160.w,
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          top: 101.h,
          left: 137.w,
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/unsplash_CHqrLlwebdM.png'),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80.h,
          left: 95.w,
          child: Text(
            userProfileState.profileData?['name'] ?? 'Loading...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          bottom: 60.h,
          left: 85.w,
          child: Text(
            _formatJobTitle(userProfileState.profileData),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          bottom: 23.h,
          left: 30.w,
          child: Icon(Icons.phone, size: 14.sp),
        ),
        Positioned(
          bottom: 20.h,
          left: 50.w,
          child: Text(
            userProfileState.profileData?['work_phone'] ?? 'N/A',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          bottom: 29.h,
          left: 200.w,
          child: Container(
            width: 5.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 24.h,
          right: 143.w,
          child: Icon(Icons.email, size: 14.sp),
        ),
        Positioned(
          bottom: 21.h,
          right: 25.w,
          child: Text(
            userProfileState.profileData?['work_email'] ?? 'N/A',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _formatJobTitle(Map<String, dynamic>? profileData) {
    if (profileData == null) {
      return 'Loading...';
    }

    final jobTitle = profileData['job_title'] ?? 'N/A';
    final department = profileData['department'] ?? 'N/A';

    if (jobTitle == 'N/A' && department == 'N/A') {
      return 'Employee';
    } else if (jobTitle == 'N/A') {
      return department;
    } else if (department == 'N/A') {
      return jobTitle;
    } else {
      return '$jobTitle – $department';
    }
  }
}
