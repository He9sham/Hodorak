import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';

import '../../model/setting_model.dart';
import '../../viewmodel/setting_viewmodel.dart';

/// Widget for theme settings section
class ThemeSettingsWidget extends StatelessWidget {
  final SettingModel settings;
  final SettingNotifier viewModel;
  final Function(String) onShowSnackBar;

  const ThemeSettingsWidget({
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
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(
              'Currently using ${settings.themeModeName.toLowerCase()} theme',
            ),
            leading: Icon(
              _getThemeModeIcon(settings.themeModeIndex),
              color: Theme.of(context).colorScheme.primary,
            ),
            trailing: DropdownButton<int>(
              value: settings.themeModeIndex,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  viewModel.setThemeMode(newValue);
                  onShowSnackBar(
                    'Switched to ${_getThemeModeName(newValue).toLowerCase()} theme',
                  );
                }
              },
              items: [
                DropdownMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.brightness_auto, size: 20),
                      horizontalSpace(8),
                      const Text('System'),
                    ],
                  ),
                ),
                DropdownMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.light_mode, size: 20),
                      horizontalSpace(8),
                      const Text('Light'),
                    ],
                  ),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode, size: 20),
                      horizontalSpace(8),
                      const Text('Dark'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Theme Preview Section
          _buildThemePreview(context),
        ],
      ),
    );
  }

  /// Build theme preview section
  Widget _buildThemePreview(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme Preview',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          verticalSpace(8),
          Row(
            children: [
              Expanded(
                child: _buildColorPreview(
                  context,
                  'Primary',
                  Icons.color_lens,
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: _buildColorPreview(
                  context,
                  'Secondary',
                  Icons.palette,
                  Theme.of(context).colorScheme.secondaryContainer,
                  Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: _buildColorPreview(
                  context,
                  'Tertiary',
                  Icons.brush,
                  Theme.of(context).colorScheme.tertiaryContainer,
                  Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual color preview container
  Widget _buildColorPreview(
    BuildContext context,
    String label,
    IconData icon,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: foregroundColor),
          verticalSpace(4),
          Text(
            label,
            style: TextStyle(color: foregroundColor, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  /// Get theme mode icon based on index
  IconData _getThemeModeIcon(int index) {
    switch (index) {
      case 0:
        return Icons.brightness_auto;
      case 1:
        return Icons.light_mode;
      case 2:
        return Icons.dark_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  /// Get theme mode name based on index
  String _getThemeModeName(int index) {
    switch (index) {
      case 0:
        return 'System';
      case 1:
        return 'Light';
      case 2:
        return 'Dark';
      default:
        return 'System';
    }
  }
}
