import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/providers/auth_state_manager.dart';
import 'package:hodorak/core/providers/user_profile_provider.dart';

class ShowDetailsWidget extends ConsumerWidget {
  const ShowDetailsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(userProfileProvider);
    final authState = ref.watch(authStateManagerProvider);

    return Stack(
      children: [
        Container(
          height: 316.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xffF5BA3A),
                Color(0xff8C9F5F), // You can adjust this color
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
        ),
        Positioned(
          top: 70.h,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          top: 101.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 38.r,
                  backgroundColor: Color(0xff8C9F5F).withValues(alpha: 0.1),
                  child: Text(
                    authState.name?.isNotEmpty == true
                        ? authState.name![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff8C9F5F),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80.h,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              userProfileState.profileData?['name'] ?? 'Loading...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          bottom: 60.h,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              _formatJobTitle(userProfileState.profileData),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          bottom: 23.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 14.sp, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text(
                    userProfileState.profileData?['work_phone'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                width: 5.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email, size: 14.sp, color: Colors.white),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      userProfileState.profileData?['work_email'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
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
