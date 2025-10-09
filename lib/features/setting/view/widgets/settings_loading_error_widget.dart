import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

import '../../viewmodel/setting_viewmodel.dart';

/// Widget for loading and error states in settings screen
class SettingsLoadingErrorWidget extends StatelessWidget {
  final SettingNotifier viewModel;

  const SettingsLoadingErrorWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message if there's an error
    if (viewModel.error != null) {
      return _buildErrorWidget(context);
    }

    // This widget should not be shown if there's no loading or error
    return const SizedBox.shrink();
  }

  /// Build error widget
  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          verticalSpace(16),
          Text(
            'Error loading settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          verticalSpace(8),
          Text(
            viewModel.error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          verticalSpace(16),
          ElevatedButton(
            onPressed: () {
              viewModel.clearError();
              viewModel.initialize();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
