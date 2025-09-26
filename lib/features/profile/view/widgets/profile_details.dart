import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/user_profile_provider.dart';
import 'package:hodorak/features/profile/view/widgets/profile_details_employee.dart';

class ProfileDetails extends ConsumerWidget {
  const ProfileDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(userProfileProvider);

    return Container(
      width: 343.w,
      height: 125.h,
      decoration: BoxDecoration(
        color: Color.fromARGB(237, 225, 225, 228),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 20),
        child: userProfileState.isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blue))
            : userProfileState.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 24),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load profile',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    TextButton(
                      onPressed: () => ref
                          .read(userProfileProvider.notifier)
                          .refreshProfile(),
                      child: Text('Retry', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  ProfileDetailsEmployee(
                    title: 'Employee ID',
                    subtitle:
                        userProfileState.profileData?['employee_id']
                            ?.toString() ??
                        'N/A',
                  ),
                  verticalSpace(16),
                  ProfileDetailsEmployee(
                    title: 'National ID',
                    subtitle:
                        userProfileState.profileData?['national_id'] ?? 'N/A',
                  ),
                  verticalSpace(16),
                  ProfileDetailsEmployee(
                    title: 'Hire Date',
                    subtitle: _formatHireDate(
                      userProfileState.profileData?['hire_date'],
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
