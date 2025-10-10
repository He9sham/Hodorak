import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

import '../viewmodel/setting_viewmodel.dart';
import 'widgets/widgets.dart';

/// Settings screen implementing MVVM architecture with Riverpod
/// Uses Material 3 design with ListView and ListTile widgets
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

    // Show loading or error state
    if (viewModel.isLoading || viewModel.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: SettingsLoadingErrorWidget(viewModel: viewModel),
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
          // Notification Settings Section
          SectionHeaderWidget(title: 'Notifications'),
          NotificationSettingsWidget(
            settings: settings,
            viewModel: viewModel,
            onShowSnackBar: _showSnackBar,
          ),

          verticalSpace(24),

          // Language Settings Section (Coming Soon)
          SectionHeaderWidget(title: 'Language'),
          const LanguageSettingsWidget(),

          verticalSpace(24),

          // About App Section
          SectionHeaderWidget(title: 'About'),
          AboutAppWidget(settings: settings),

          verticalSpace(24),

          // Reset Settings Section
          SectionHeaderWidget(title: 'Advanced'),
          AdvancedSettingsWidget(
            viewModel: viewModel,
            onShowSnackBar: _showSnackBar,
          ),

          verticalSpace(32),
        ],
      ),
    );
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    SettingsSnackbarUtil.showSnackBar(context, message);
  }
}
