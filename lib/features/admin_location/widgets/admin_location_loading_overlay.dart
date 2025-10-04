import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/features/admin_location/constants/admin_location_constants.dart';
import 'package:hodorak/features/admin_location/controllers/admin_location_controller.dart';

class AdminLocationLoadingOverlay extends ConsumerWidget {
  final Widget child;

  const AdminLocationLoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminLocationControllerProvider);

    return Stack(
      children: [
        child,
        if (state.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(AdminLocationConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AdminLocationConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(
                    AdminLocationConstants.borderRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AdminLocationConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: AdminLocationConstants.bodyFontSize,
                        color: AdminLocationConstants.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
