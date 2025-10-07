import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/theming/styles.dart';
import 'package:hodorak/features/auth/views/widgets/custom_text_field_auth.dart';
import 'package:hodorak/features/auth/views/widgets/label_text_field.dart';
import 'package:hodorak/features/company_screen/viewmodels/company_creation_viewmodel.dart';

class CompanyInfoSection extends ConsumerWidget {
  const CompanyInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(companyCreationNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Text
        Text(
          'Create your company profile',
          style: Styles.textSize13Black600.copyWith(fontSize: 16.sp),
        ),
        verticalSpace(8),
        Text(
          'Fill in the details below to create your company account.',
          style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
        ),

        verticalSpace(32),

        // Company Name (Required)
        LabelTextField(title: 'Company Name *'),
        verticalSpace(8),
        CustomTextFieldAuth(
          controller: viewModel.companyNameController,
          hintText: 'Enter your company name',
          validator: viewModel.validateCompanyName,
        ),

        verticalSpace(16),

        // Description
        LabelTextField(title: 'Description'),
        verticalSpace(8),
        CustomTextFieldAuth(
          controller: viewModel.descriptionController,
          hintText: 'Brief description of your company (Optional)',
          maxLines: 3,
          validator: viewModel.validateDescription,
        ),

        verticalSpace(16),

        // Phone
        LabelTextField(title: 'Phone Number'),
        verticalSpace(8),
        CustomTextFieldAuth(
          controller: viewModel.phoneController,
          hintText: 'Company phone number (Optional)',
          keyboardType: TextInputType.phone,
          validator: viewModel.validatePhone,
        ),

        verticalSpace(16),

        // Email
        LabelTextField(title: 'Email'),
        verticalSpace(8),
        CustomTextFieldAuth(
          controller: viewModel.emailController,
          hintText: 'Company email (Optional)',
          keyboardType: TextInputType.emailAddress,
          validator: viewModel.validateEmail,
        ),
      ],
    );
  }
}
