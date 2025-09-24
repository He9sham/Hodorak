import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/features/profile/view/widgets/custom_navigation_button.dart';
import 'package:hodorak/features/profile/view/widgets/show_details_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ShowDetailsWidget(),
          verticalSpace(72),
          CustomNavigationButton(
            iconSize: 100,
            title: 'Personal Information',
            icons: Icons.info_outline,
          ),
          verticalSpace(16),
          CustomNavigationButton(title: 'Setting', icons: Icons.settings),
        ],
      ),
    );
  }
}
