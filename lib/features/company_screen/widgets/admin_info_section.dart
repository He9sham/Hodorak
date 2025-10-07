import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/features/auth/views/widgets/custom_text_field_auth.dart';
import 'package:hodorak/features/auth/views/widgets/label_text_field.dart';
import 'package:hodorak/features/company_screen/viewmodels/company_creation_viewmodel.dart';

class AdminInfoSection extends ConsumerWidget {
  const AdminInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(companyCreationNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Admin Name (Required)
        LabelTextField(title: 'Admin Name *'),
        verticalSpace(8),
        CustomTextFieldAuth(
          controller: viewModel.adminNameController,
          hintText: 'Enter admin full name',
          validator: viewModel.validateAdminName,
        ),

        verticalSpace(16),

        // Admin Email (Required)
        LabelTextField(title: 'Admin Email *'),
        verticalSpace(8),
        CustomTextFieldAuth(
          controller: viewModel.adminEmailController,
          hintText: 'Enter admin email address',
          keyboardType: TextInputType.emailAddress,
          validator: viewModel.validateAdminEmail,
        ),

        verticalSpace(16),

        // Admin Password (Required)
        LabelTextField(title: 'Admin Password *'),
        verticalSpace(8),
        CustomTextFieldAuth(
          controller: viewModel.adminPasswordController,
          hintText: 'Enter admin password',
          isObscureText: true,
          validator: viewModel.validateAdminPassword,
        ),
      ],
    );
  }
}
