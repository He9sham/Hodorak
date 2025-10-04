import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminLocationConstants {
  // Colors
  static const Color primaryColor = Color(0xff8C9F5F);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color hintColor = Colors.grey;

  // Map settings
  static const double defaultZoom = 15.0;
  static const double minZoom = 10.0;
  static const double maxZoom = 20.0;
  static const LatLng defaultLocation = LatLng(
    37.7749,
    -122.4194,
  ); // San Francisco
  static const double defaultRadius = 100.0;
  static const double minRadius = 10.0;
  static const double maxRadius = 500.0;
  static const int radiusDivisions = 49;

  // UI dimensions
  static const double mapFlex = 3;
  static const double controlsFlex = 2;
  static const double defaultPadding = 16.0;
  static const double buttonHeight = 48.0;
  static const double borderRadius = 8.0;
  static const double iconSize = 24.0;
  static const double progressIndicatorSize = 20.0;

  // Text styles
  static const String defaultFontFamily = 'Roboto';
  static const double titleFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const FontWeight titleFontWeight = FontWeight.bold;
  static const FontWeight bodyFontWeight = FontWeight.normal;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Location accuracy
  static const LocationAccuracy locationAccuracy = LocationAccuracy.high;
  static const Duration locationTimeout = Duration(seconds: 10);

  // Validation
  static const int minLocationNameLength = 2;
  static const int maxLocationNameLength = 100;

  // Error messages
  static const String errorSelectLocation =
      'Please select a location on the map';
  static const String errorEnterLocationName = 'Please enter a location name';
  static const String errorLocationNameTooShort =
      'Location name must be at least 2 characters';
  static const String errorLocationNameTooLong =
      'Location name must be less than 100 characters';
  static const String errorGetCurrentLocation =
      'Could not get current location';
  static const String errorSaveLocation = 'Failed to save workplace location';
  static const String errorClearLocation = 'Failed to clear workplace location';
  static const String errorLoadLocation = 'Failed to load existing location';

  // Success messages
  static const String successLocationSaved =
      'Workplace location saved successfully';
  static const String successLocationCleared =
      'Workplace location cleared successfully';

  // Dialog messages
  static const String dialogClearTitle = 'Clear Location';
  static const String dialogClearMessage =
      'Are you sure you want to clear the workplace location?';
  static const String dialogCancelButton = 'Cancel';
  static const String dialogConfirmButton = 'Confirm';

  // Button labels
  static const String buttonSaveLocation = 'Save Location';
  static const String buttonClearLocation = 'Clear Location';
  static const String buttonUseCurrentLocation = 'Use My Current Location';
  static const String buttonGetCurrentLocation = 'Get My Current Location';
  static const String buttonGettingLocation = 'Getting Location...';

  // Field labels
  static const String labelLocationName = 'Location Name';
  static const String labelAllowedRadius = 'Allowed Radius';
  static const String labelLocationSettings = 'Location Settings';
  static const String hintLocationName = 'e.g., Main Office, Branch Office';

  // Info window text
  static const String infoCurrentLocationTitle = 'Your Current Location';
  static const String infoCurrentLocationSnippet =
      'Tap "Use My Current Location" to set this as workplace';
  static const String infoWorkplaceLocationTitle = 'Workplace Location';
  static const String infoWorkplaceLocationSnippet =
      'Allowed radius: {radius}m';

  // Screen title
  static const String screenTitle = 'Set Workplace Location';

  // Marker IDs
  static const String markerCurrentLocationId = 'current_location';
  static const String markerWorkplaceId = 'workplace';

  // Circle ID
  static const String circleAllowedRadiusId = 'allowed_radius';

  // Marker colors
  static const double markerCurrentLocationHue = BitmapDescriptor.hueBlue;
  static const double markerWorkplaceHue = BitmapDescriptor.hueRed;

  // Circle styling
  static const double circleStrokeWidth = 2.0;
  static const double circleFillOpacity = 0.2;
}
