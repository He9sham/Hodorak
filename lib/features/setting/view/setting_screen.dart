import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

import '../viewmodel/setting_viewmodel.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize settings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(settingProvider.notifier);
    final settings = ref.watch(settingProvider);

    // Show loading indicator while initializing
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message if there's an error
    if (viewModel.error != null) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.sp),
        children: [
          // Theme Settings Section
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark theme'),
                  value: settings.isDarkMode,
                  onChanged: (value) => viewModel.toggleThemeMode(),
                  secondary: Icon(
                    settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          verticalSpace(24),

          // Notification Settings Section
          _buildSectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text(
                    'Receive push notifications for important updates',
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (value) => viewModel.toggleNotifications(),
                  secondary: Icon(
                    settings.notificationsEnabled
                        ? Icons.notifications
                        : Icons.notifications_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          verticalSpace(24),

          // Language Settings Section (Coming Soon)
          _buildSectionHeader('Language'),
          Card(
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
          ),

          verticalSpace(24),

          // About App Section
          _buildSectionHeader('About'),
          Card(
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
          ),

          verticalSpace(24),

          // Reset Settings Section
          _buildSectionHeader('Advanced'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Reset Settings'),
                  subtitle: const Text('Reset all settings to default values'),
                  leading: Icon(
                    Icons.restore,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onTap: () => _showResetDialog(context, viewModel),
                ),
              ],
            ),
          ),

          verticalSpace(32),
        ],
      ),
    );
  }

  /// Build section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Show reset confirmation dialog
  void _showResetDialog(BuildContext context, SettingNotifier viewModel) {
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
                _showSnackBar(context, 'Settings reset to defaults');
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  /// Show snackbar message
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
