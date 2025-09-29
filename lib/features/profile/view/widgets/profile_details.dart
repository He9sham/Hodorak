import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/user_profile_provider.dart';
import 'package:hodorak/features/profile/view/widgets/profile_details_employee.dart';

class ProfileDetails extends ConsumerWidget {
  ProfileDetails({super.key});
  final List<String> modelTitle = ['employee_id', 'national_id', 'hire_date'];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(userProfileProvider);

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
                          .read(userProfileProvider.notifier)
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
                    subtitle:
                        userProfileState.profileData?[modelTitle[0]]
                            ?.toString() ??
                        'N/A',
                  ),
                  verticalSpace(16),
                  ProfileDetailsEmployee(
                    title: 'National ID',
                    subtitle:
                        userProfileState.profileData?[modelTitle[1]]
                            .toString() ??
                        'Not Set',
                  ),
                  verticalSpace(16),
                  ProfileDetailsEmployee(
                    title: 'Hire Date',
                    subtitle: _formatHireDate(
                      userProfileState.profileData?[modelTitle[2]],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatHireDate(dynamic hireDate) {
    if (hireDate == null || hireDate == 'N/A') {
      return 'N/A';
    }

    try {
      // Parse the date string and format it
      final date = DateTime.parse(hireDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return hireDate.toString();
    }
  }
}
