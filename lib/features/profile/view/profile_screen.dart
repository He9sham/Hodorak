import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/supabase_user_profile_provider.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/profile/view/widgets/profile_details.dart';
import 'package:hodorak/features/profile/view/widgets/show_details_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Delay the provider modification until after the widget tree is built
    Future(() => _initializeProfile());
  }

  Future<void> _initializeProfile() async {
    try {
      await ref
          .read(supabaseUserProfileProvider.notifier)
          .initializeUserProfile();
    } catch (e) {
      Logger.error('Profile initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [ShowDetailsWidget(), verticalSpace(25), ProfileDetails()],
      ),
    );
  }
}
