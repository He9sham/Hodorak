import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/workplace_location.dart';
import 'package:hodorak/core/providers/location_provider.dart';
import 'package:hodorak/core/utils/logger.dart';

class AdminLocationScreen extends ConsumerStatefulWidget {
  const AdminLocationScreen({super.key});

  @override
  ConsumerState<AdminLocationScreen> createState() =>
      _AdminLocationScreenState();
}

class _AdminLocationScreenState extends ConsumerState<AdminLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  String _locationName = '';
  double _allowedRadius = 100.0;
  bool _isLoading = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadExistingLocation();
    _getCurrentLocation();
  }

  Future<void> _loadExistingLocation() async {
    final workplaceState = ref.read(workplaceLocationProvider);
    if (workplaceState.location != null) {
      setState(() {
        _selectedLocation = LatLng(
          workplaceState.location!.latitude,
          workplaceState.location!.longitude,
        );
        _locationName = workplaceState.location!.name;
        _allowedRadius = workplaceState.location!.allowedRadius;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final userLocation = await locationService.getCurrentLocation();

      if (userLocation != null) {
        setState(() {
          _currentLocation = LatLng(
            userLocation.latitude,
            userLocation.longitude,
          );
        });

        // Move camera to current location if no workplace location is set
        if (_selectedLocation == null && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentLocation!),
          );
        }
      }
    } catch (e) {
      // Handle location error silently - just don't set current location
      Logger.error('Error getting current location: $e');
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // If we have an existing workplace location, move camera to it
    if (_selectedLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
    }
    // If we have current location but no workplace location, move camera to current location
    else if (_currentLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    }
  }

  Future<void> _saveLocation() async {
    if (_selectedLocation == null) {
      _showErrorMessage('Please select a location on the map');
      return;
    }

    if (_locationName.trim().isEmpty) {
      _showErrorMessage('Please enter a location name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final workplaceLocation = WorkplaceLocation(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        name: _locationName.trim(),
        allowedRadius: _allowedRadius,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(workplaceLocationProvider.notifier)
          .saveWorkplaceLocation(workplaceLocation);

      if (success) {
        _showSuccessMessage('Workplace location saved successfully');
        // Debug: Check if location was actually saved
        await ref.read(locationServiceProvider).debugSharedPreferences();
      } else {
        _showErrorMessage('Failed to save workplace location');
      }
    } catch (e) {
      _showErrorMessage('Error saving location: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearLocation() async {
    final confirmed = await _showConfirmDialog(
      'Clear Location',
      'Are you sure you want to clear the workplace location?',
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await ref
            .read(workplaceLocationProvider.notifier)
            .clearWorkplaceLocation();

        if (success) {
          setState(() {
            _selectedLocation = null;
            _locationName = '';
            _allowedRadius = 100.0;
          });
          _showSuccessMessage('Workplace location cleared successfully');
        } else {
          _showErrorMessage('Failed to clear workplace location');
        }
      } catch (e) {
        _showErrorMessage('Error clearing location: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Workplace Location'),
        backgroundColor: Color(0xff8C9F5F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target:
                    _selectedLocation ??
                    _currentLocation ??
                    const LatLng(
                      37.7749,
                      -122.4194,
                    ), // Default to San Francisco if no location available
                zoom: 15.0,
              ),
              onTap: _onMapTap,
              markers: {
                // Current location marker
                if (_currentLocation != null)
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: _currentLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                    infoWindow: const InfoWindow(
                      title: 'Your Current Location',
                      snippet:
                          'Tap "Use My Current Location" to set this as workplace',
                    ),
                  ),
                // Workplace location marker
                if (_selectedLocation != null)
                  Marker(
                    markerId: const MarkerId('workplace'),
                    position: _selectedLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                    infoWindow: InfoWindow(
                      title: _locationName.isNotEmpty
                          ? _locationName
                          : 'Workplace Location',
                      snippet: 'Allowed radius: ${_allowedRadius.toInt()}m',
                    ),
                  ),
              },
              circles: _selectedLocation != null
                  ? {
                      Circle(
                        circleId: const CircleId('allowed_radius'),
                        center: _selectedLocation!,
                        radius: _allowedRadius,
                        fillColor: Colors.blue.withValues(alpha: 0.2),
                        strokeColor: Colors.blue,
                        strokeWidth: 2,
                      ),
                    }
                  : {},
            ),
          ),

          // Controls
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Settings',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    verticalSpace(16),

                    // Location Name
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Location Name',
                        hintText: 'e.g., Main Office, Branch Office',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _locationName),
                      onChanged: (value) {
                        setState(() {
                          _locationName = value;
                        });
                      },
                    ),
                    verticalSpace(16),

                    // Allowed Radius
                    Text(
                      'Allowed Radius: ${_allowedRadius.toInt()} meters',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    Slider(
                      value: _allowedRadius,
                      min: 10.0,
                      max: 500.0,
                      divisions: 49,
                      label: '${_allowedRadius.toInt()}m',
                      onChanged: (value) {
                        setState(() {
                          _allowedRadius = value;
                        });
                      },
                    ),
                    verticalSpace(16),

                    // Use Current Location Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isGettingLocation
                            ? null
                            : () {
                                if (_currentLocation != null) {
                                  setState(() {
                                    _selectedLocation = _currentLocation;
                                  });
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(_currentLocation!),
                                  );
                                } else {
                                  _getCurrentLocation();
                                }
                              },
                        icon: _isGettingLocation
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.my_location),
                        label: Text(
                          _isGettingLocation
                              ? 'Getting Location...'
                              : (_currentLocation != null
                                    ? 'Use My Current Location'
                                    : 'Get My Current Location'),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xff8C9F5F),
                          side: BorderSide(color: Color(0xff8C9F5F)),
                        ),
                      ),
                    ),
                    verticalSpace(16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff8C9F5F),
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Save Location',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        horizontalSpace(16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _clearLocation,
                            child: Text(
                              'Clear Location',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
