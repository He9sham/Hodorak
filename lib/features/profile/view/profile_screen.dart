import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/features/profile/view/widgets/profile_details.dart';
import 'package:hodorak/features/profile/view/widgets/show_details_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [ShowDetailsWidget(), verticalSpace(25), ProfileDetails()],
      ),
    );
  }
}
