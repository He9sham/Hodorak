import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/theming/styles.dart';
import 'package:hodorak/features/company_screen/viewmodels/company_creation_viewmodel.dart';
import 'package:hodorak/features/company_screen/widgets/admin_info_section.dart';
import 'package:hodorak/features/company_screen/widgets/company_creation_buttons.dart';
import 'package:hodorak/features/company_screen/widgets/company_creation_info_card.dart';
import 'package:hodorak/features/company_screen/widgets/company_info_section.dart';

class CompanyCreationScreen extends ConsumerStatefulWidget {
  const CompanyCreationScreen({super.key});

  @override
  ConsumerState<CompanyCreationScreen> createState() =>
      _CompanyCreationScreenState();
}

class _CompanyCreationScreenState extends ConsumerState<CompanyCreationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the view model
    ref.read(companyCreationNotifierProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(companyCreationNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Company',
          style: Styles.textSize13Black600.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(20),

                  // Company Information Section
                  const CompanyInfoSection(),

                  verticalSpace(32),

                  // Admin Information Section
                  const AdminInfoSection(),

                  // Action Buttons
                  const CompanyCreationButtons(),

                  verticalSpace(20),

                  // Info Card
                  const CompanyCreationInfoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
