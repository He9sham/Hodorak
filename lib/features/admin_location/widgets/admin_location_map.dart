import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hodorak/features/admin_location/constants/admin_location_constants.dart';
import 'package:hodorak/features/admin_location/controllers/admin_location_controller.dart';

class AdminLocationMap extends ConsumerStatefulWidget {
  const AdminLocationMap({super.key});

  @override
  ConsumerState<AdminLocationMap> createState() => _AdminLocationMapState();
}

class _AdminLocationMapState extends ConsumerState<AdminLocationMap> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCameraToInitialPosition();
  }

  void _onMapTap(LatLng location) {
    ref
        .read(adminLocationControllerProvider.notifier)
        .updateSelectedLocation(location);
  }

  void _moveCameraToInitialPosition() {
    final state = ref.read(adminLocationControllerProvider);

    // If we have an existing workplace location, move camera to it
    if (state.selectedLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(state.selectedLocation!),
      );
    }
    // If we have current location but no workplace location, move camera to current location
    else if (state.currentLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(state.currentLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(adminLocationControllerProvider);

        // Move camera when location changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.selectedLocation != null && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(state.selectedLocation!),
            );
          }
        });

        return GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target:
                state.selectedLocation ??
                state.currentLocation ??
                AdminLocationConstants.defaultLocation,
            zoom: AdminLocationConstants.defaultZoom,
          ),
          onTap: _onMapTap,
          markers: _buildMarkers(state),
          circles: _buildCircles(state),
          minMaxZoomPreference: MinMaxZoomPreference(
            AdminLocationConstants.minZoom,
            AdminLocationConstants.maxZoom,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        );
      },
    );
  }

  Set<Marker> _buildMarkers(AdminLocationState state) {
    final markers = <Marker>{};

    // Current location marker
    if (state.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId(
            AdminLocationConstants.markerCurrentLocationId,
          ),
          position: state.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            AdminLocationConstants.markerCurrentLocationHue,
          ),
          infoWindow: const InfoWindow(
            title: AdminLocationConstants.infoCurrentLocationTitle,
            snippet: AdminLocationConstants.infoCurrentLocationSnippet,
          ),
        ),
      );
    }

    // Workplace location marker
    if (state.selectedLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId(AdminLocationConstants.markerWorkplaceId),
          position: state.selectedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            AdminLocationConstants.markerWorkplaceHue,
          ),
          infoWindow: InfoWindow(
            title: state.locationName.isNotEmpty
                ? state.locationName
                : AdminLocationConstants.infoWorkplaceLocationTitle,
            snippet: AdminLocationConstants.infoWorkplaceLocationSnippet
                .replaceAll('{radius}', state.allowedRadius.toInt().toString()),
          ),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles(AdminLocationState state) {
    if (state.selectedLocation == null) return {};

    return {
      Circle(
        circleId: const CircleId(AdminLocationConstants.circleAllowedRadiusId),
        center: state.selectedLocation!,
        radius: state.allowedRadius,
        fillColor: AdminLocationConstants.primaryColor.withValues(
          alpha: AdminLocationConstants.circleFillOpacity,
        ),
        strokeColor: AdminLocationConstants.primaryColor,
        strokeWidth: AdminLocationConstants.circleStrokeWidth.toInt(),
      ),
    };
  }
}
