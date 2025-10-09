import 'package:flutter/material.dart';

import '../../model/setting_model.dart';
import '../../viewmodel/setting_viewmodel.dart';

/// Widget for notification settings section
class NotificationSettingsWidget extends StatelessWidget {
  final SettingModel settings;
  final SettingNotifier viewModel;
  final Function(String) onShowSnackBar;

  const NotificationSettingsWidget({
    super.key,
    required this.settings,
    required this.viewModel,
    required this.onShowSnackBar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text(
              'Receive push notifications for important updates',
            ),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              viewModel.toggleNotifications();
              onShowSnackBar(
                settings.notificationsEnabled
                    ? 'Notifications disabled'
                    : 'Notifications enabled',
              );
            },
            secondary: Icon(
              settings.notificationsEnabled
                  ? Icons.notifications
                  : Icons.notifications_off,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
