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
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(supabaseAuthProvider.notifier).logout();
              if (context.mounted) {
                context.pushReplacementNamed(Routes.loginScreen);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              WelcomeSection(authState: authState),
              verticalSpace(24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              verticalSpace(16),

              // Action Cards Row One
              BuildItemCartRowOne(),
              verticalSpace(12),

              // Action Cards Row two
              BuildItemCartRowTwo(),
              verticalSpace(12),

              // Action Cards Row three
              BuildItemCartRowThree(),
              verticalSpace(12),

              // Action Cards Row four
              BuildItemCartRowFour(),
              verticalSpace(12),
            ],
          ),
        ),
      ),
    );
  }
}
