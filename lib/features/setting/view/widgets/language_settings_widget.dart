import 'package:flutter/material.dart';

/// Widget for language settings section (Coming Soon)
class LanguageSettingsWidget extends StatelessWidget {
  const LanguageSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Language'),
            subtitle: const Text('Coming Soon'),
            leading: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.outline,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
            enabled: false, // Disabled to show it's coming soon
            onTap: () {
              // No functionality yet - coming soon
            },
          ),
        ],
      ),
    );
  }
}
