import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/supabase_user_profile_provider.dart';
import 'package:hodorak/features/profile/view/widgets/profile_details_employee.dart';

class ProfileDetails extends ConsumerWidget {
  const ProfileDetails({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(supabaseUserProfileProvider);

    return Container(
      width: 343.w,
      height: 136.h,
      decoration: BoxDecoration(
        color: Color.fromARGB(237, 225, 225, 228),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: userProfileState.isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blue))
            : userProfileState.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
                    SizedBox(height: 8.h),
                    Text(
                      'Failed to load profile',
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                    SizedBox(height: 4.h),
                    TextButton(
                      onPressed: () => ref
                          .read(supabaseUserProfileProvider.notifier)
                          .refreshProfile(),
                      child: Text('Retry', style: TextStyle(fontSize: 12.sp)),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  ProfileDetailsEmployee(
                    title: 'Employee ID',
                    subtitle: _formatEmployeeId(
                      userProfileState.profileData?.id,
                    ),
                  ),
                  verticalSpace(16),
                  ProfileDetailsEmployee(
                    title: 'National ID',
                    subtitle:
                        userProfileState.profileData?.nationalId ?? 'Not Set',
                  ),
                  verticalSpace(16),
                  ProfileDetailsEmployee(
                    title: 'Hire Date',
                    subtitle: _formatHireDate(
                      userProfileState.profileData?.createdAt,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatHireDate(DateTime? hireDate) {
    if (hireDate == null) {
      return 'N/A';
    }

    return '${hireDate.day}/${hireDate.month}/${hireDate.year}';
  }

  String _formatEmployeeId(String? employeeId) {
    if (employeeId == null || employeeId.isEmpty) {
      return 'N/A';
    }

    // Show only the first 7 digits of the Employee ID
    if (employeeId.length >= 7) {
      return employeeId.substring(0, 7);
    } else {
      return employeeId;
    }
  }
}
