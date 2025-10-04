import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/features/admin_location/constants/admin_location_constants.dart';
import 'package:hodorak/features/admin_location/controllers/admin_location_controller.dart';

class AdminLocationControls extends ConsumerStatefulWidget {
  const AdminLocationControls({super.key});

  @override
  ConsumerState<AdminLocationControls> createState() =>
      _AdminLocationControlsState();
}

class _AdminLocationControlsState extends ConsumerState<AdminLocationControls> {
  final TextEditingController _locationNameController = TextEditingController();

  @override
  void dispose() {
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(adminLocationControllerProvider);

        // Update text controller when state changes
        if (_locationNameController.text != state.locationName) {
          _locationNameController.text = state.locationName;
        }

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(AdminLocationConstants.defaultPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                verticalSpace(16),
                _buildLocationNameField(ref, state),
                verticalSpace(16),
                _buildRadiusSlider(ref, state),
                verticalSpace(16),
                _buildUseCurrentLocationButton(ref, state),
                verticalSpace(16),
                _buildActionButtons(ref, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      AdminLocationConstants.labelLocationSettings,
      style: TextStyle(
        fontSize: AdminLocationConstants.titleFontSize.sp,
        fontWeight: AdminLocationConstants.titleFontWeight,
        color: AdminLocationConstants.textColor,
      ),
    );
  }

  Widget _buildLocationNameField(WidgetRef ref, AdminLocationState state) {
    return TextField(
      controller: _locationNameController,
      decoration: InputDecoration(
        labelText: AdminLocationConstants.labelLocationName,
        hintText: AdminLocationConstants.hintLocationName,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AdminLocationConstants.borderRadius,
          ),
        ),
        errorText: _getLocationNameError(state),
      ),
      onChanged: (value) {
        ref
            .read(adminLocationControllerProvider.notifier)
            .updateLocationName(value);
      },
      maxLength: AdminLocationConstants.maxLocationNameLength,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildRadiusSlider(WidgetRef ref, AdminLocationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AdminLocationConstants.labelAllowedRadius}: ${state.allowedRadius.toInt()} meters',
          style: TextStyle(
            fontSize: AdminLocationConstants.bodyFontSize.sp,
            color: AdminLocationConstants.textColor,
          ),
        ),
        Slider(
          value: state.allowedRadius,
          min: AdminLocationConstants.minRadius,
          max: AdminLocationConstants.maxRadius,
          divisions: AdminLocationConstants.radiusDivisions,
          label: '${state.allowedRadius.toInt()}m',
          onChanged: (value) {
            ref
                .read(adminLocationControllerProvider.notifier)
                .updateAllowedRadius(value);
          },
          activeColor: AdminLocationConstants.primaryColor,
        ),
      ],
    );
  }

  Widget _buildUseCurrentLocationButton(
    WidgetRef ref,
    AdminLocationState state,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: state.isGettingLocation ? null : _handleUseCurrentLocation,
        icon: state.isGettingLocation
            ? SizedBox(
                width: AdminLocationConstants.iconSize,
                height: AdminLocationConstants.iconSize,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
        label: Text(
          _getUseCurrentLocationButtonText(state),
          style: TextStyle(fontSize: AdminLocationConstants.bodyFontSize.sp),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminLocationConstants.primaryColor,
          side: BorderSide(color: AdminLocationConstants.primaryColor),
          minimumSize: Size(
            double.infinity,
            AdminLocationConstants.buttonHeight.h,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref, AdminLocationState state) {
    return Row(
      children: [
        Expanded(child: _buildSaveButton(ref, state)),
        horizontalSpace(16),
        Expanded(child: _buildClearButton(ref, state)),
      ],
    );
  }

  Widget _buildSaveButton(WidgetRef ref, AdminLocationState state) {
    return ElevatedButton(
      onPressed: state.isLoading ? null : _handleSaveLocation,
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminLocationConstants.primaryColor,
        foregroundColor: AdminLocationConstants.backgroundColor,
        minimumSize: Size(
          double.infinity,
          AdminLocationConstants.buttonHeight.h,
        ),
      ),
      child: state.isLoading
          ? SizedBox(
              height: AdminLocationConstants.progressIndicatorSize.h,
              width: AdminLocationConstants.progressIndicatorSize.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              AdminLocationConstants.buttonSaveLocation,
              style: TextStyle(
                fontSize: AdminLocationConstants.bodyFontSize.sp,
                fontWeight: AdminLocationConstants.titleFontWeight,
              ),
            ),
    );
  }

  Widget _buildClearButton(WidgetRef ref, AdminLocationState state) {
    return OutlinedButton(
      onPressed: state.isLoading ? null : _handleClearLocation,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(
          double.infinity,
          AdminLocationConstants.buttonHeight.h,
        ),
      ),
      child: Text(
        AdminLocationConstants.buttonClearLocation,
        style: TextStyle(
          fontSize: AdminLocationConstants.bodyFontSize.sp,
          fontWeight: AdminLocationConstants.titleFontWeight,
        ),
      ),
    );
  }

  String? _getLocationNameError(AdminLocationState state) {
    if (state.locationName.trim().isEmpty) return null;

    if (state.locationName.trim().length <
        AdminLocationConstants.minLocationNameLength) {
      return AdminLocationConstants.errorLocationNameTooShort;
    }

    if (state.locationName.length >
        AdminLocationConstants.maxLocationNameLength) {
      return AdminLocationConstants.errorLocationNameTooLong;
    }

    return null;
  }

  String _getUseCurrentLocationButtonText(AdminLocationState state) {
    if (state.isGettingLocation) {
      return AdminLocationConstants.buttonGettingLocation;
    }

    if (state.currentLocation != null) {
      return AdminLocationConstants.buttonUseCurrentLocation;
    }

    return AdminLocationConstants.buttonGetCurrentLocation;
  }

  void _handleUseCurrentLocation() {
    final state = ref.read(adminLocationControllerProvider);

    if (state.currentLocation != null) {
      ref.read(adminLocationControllerProvider.notifier).useCurrentLocation();
    } else {
      ref
          .read(adminLocationControllerProvider.notifier)
          .refreshCurrentLocation();
    }
  }

  Future<void> _handleSaveLocation() async {
    final success = await ref
        .read(adminLocationControllerProvider.notifier)
        .saveLocation();

    if (success) {
      _showSuccessMessage(AdminLocationConstants.successLocationSaved);
    } else {
      final state = ref.read(adminLocationControllerProvider);
      _showErrorMessage(
        state.error ?? AdminLocationConstants.errorSaveLocation,
      );
    }
  }

  Future<void> _handleClearLocation() async {
    final confirmed = await _showConfirmDialog(
      AdminLocationConstants.dialogClearTitle,
      AdminLocationConstants.dialogClearMessage,
    );

    if (confirmed == true) {
      final success = await ref
          .read(adminLocationControllerProvider.notifier)
          .clearLocation();

      if (success) {
        _showSuccessMessage(AdminLocationConstants.successLocationCleared);
      } else {
        final state = ref.read(adminLocationControllerProvider);
        _showErrorMessage(
          state.error ?? AdminLocationConstants.errorClearLocation,
        );
      }
    }
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminLocationConstants.successColor,
        duration: AdminLocationConstants.mediumAnimationDuration,
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AdminLocationConstants.dialogCancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AdminLocationConstants.dialogConfirmButton),
          ),
        ],
      ),
    );
  }
}
