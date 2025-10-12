import 'package:flutter/material.dart';

/// Dialog for confirming clear all notifications action
class ClearAllDialog extends StatelessWidget {
  const ClearAllDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => const ClearAllDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clear All Notifications'),
      content: const Text(
        'Are you sure you want to clear all notifications? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Clear All'),
        ),
      ],
    );
  }
}
