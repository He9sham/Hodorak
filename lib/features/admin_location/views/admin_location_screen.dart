import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/features/admin_location/constants/admin_location_constants.dart';
import 'package:hodorak/features/admin_location/controllers/admin_location_controller.dart';
import 'package:hodorak/features/admin_location/widgets/admin_location_controls.dart';
import 'package:hodorak/features/admin_location/widgets/admin_location_loading_overlay.dart';
import 'package:hodorak/features/admin_location/widgets/admin_location_map.dart';

class AdminLocationScreen extends ConsumerStatefulWidget {
  const AdminLocationScreen({super.key});

  @override
  ConsumerState<AdminLocationScreen> createState() =>
      _AdminLocationScreenState();
}

class _AdminLocationScreenState extends ConsumerState<AdminLocationScreen> {
  @override
  Widget build(BuildContext context) {
    // Listen to error state changes and show error messages
    ref.listen<AdminLocationState>(adminLocationControllerProvider, (
      previous,
      next,
    ) {
      if (next.error != null && previous?.error != next.error) {
        _showErrorMessage(next.error!);
        // Clear error after showing
        ref.read(adminLocationControllerProvider.notifier).clearError();
      }
    });
    return AdminLocationLoadingOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AdminLocationConstants.screenTitle),
          backgroundColor: AdminLocationConstants.primaryColor,
          foregroundColor: AdminLocationConstants.backgroundColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Map
            Expanded(
              flex: AdminLocationConstants.mapFlex.toInt(),
              child: const AdminLocationMap(),
            ),
            // Controls
            Expanded(
              flex: AdminLocationConstants.controlsFlex.toInt(),
              child: const AdminLocationControls(),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminLocationConstants.errorColor,
        duration: AdminLocationConstants.mediumAnimationDuration,
      ),
    );
  }
}
