import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/extensions.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/supabase_auth_provider.dart';
import 'package:hodorak/core/utils/routes.dart';
import 'package:hodorak/features/home/views/widgets/build_item_cart.dart';
import 'package:hodorak/features/home/views/widgets/welcome_section.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(supabaseAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hodorak',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.blue.shade700.withValues(alpha: 0.3),
        actions: [
         
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: () async {
                await ref.read(supabaseAuthProvider.notifier).logout();
                if (context.mounted) {
                  context.pushReplacementNamed(Routes.loginScreen);
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with Quick Stats
                WelcomeSection(authState: authState),
                verticalSpace(32),

                // Quick Actions Header
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      color: Colors.grey.shade900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                verticalSpace(16),

                // Action Cards Row One
                BuildItemCartRowOne(),
                verticalSpace(16),

                // Action Cards Row Two
                BuildItemCartRowTwo(),
                verticalSpace(16),

                // Action Cards Row Three
                BuildItemCartRowThree(),
                verticalSpace(16),

                // Action Cards Row Four
                BuildItemCartRowFour(),
                verticalSpace(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
