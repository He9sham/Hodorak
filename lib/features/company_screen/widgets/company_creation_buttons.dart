import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/features/login/presentation/widgets/login_button.dart';
import 'package:hodorak/features/company_screen/viewmodels/company_creation_viewmodel.dart';

class CompanyCreationButtons extends ConsumerWidget {
  const CompanyCreationButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companyCreationNotifierProvider);
    final viewModel = ref.watch(companyCreationNotifierProvider.notifier);

    return Column(
      children: [
        verticalSpace(40),

        // Create Company Button
        CustomButtonAuth(
          title: 'Create Company',
          onPressed: () async {
            final success = await viewModel.createCompany();
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Company created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(state.createdCompany);
            } else if (context.mounted && state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          isLoading: state.isLoading,
        ),

        verticalSpace(16),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }
}
