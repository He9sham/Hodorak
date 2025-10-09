import 'package:flutter/material.dart';

import '../../model/setting_model.dart';

/// Widget for about app section
class AboutAppWidget extends StatelessWidget {
  final SettingModel settings;

  const AboutAppWidget({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('App Name'),
            subtitle: Text(settings.appName),
            leading: Icon(
              Icons.apps,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Version'),
            subtitle: Text(settings.appVersion),
            leading: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Developer'),
            subtitle: Text(settings.developerName),
            leading: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
