import 'package:flutter/material.dart';

import '../../viewmodel/setting_viewmodel.dart';

/// Widget for advanced settings section
class AdvancedSettingsWidget extends StatelessWidget {
  final SettingNotifier viewModel;
  final Function(String) onShowSnackBar;

  const AdvancedSettingsWidget({
    super.key,
    required this.viewModel,
    required this.onShowSnackBar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Reset Settings'),
            subtitle: const Text('Reset all settings to default values'),
            leading: Icon(
              Icons.restore,
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () => _showResetDialog(context),
          ),
        ],
      ),
    );
  }

  /// Show reset confirmation dialog
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.resetToDefaults();
                onShowSnackBar('Settings reset to defaults');
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
