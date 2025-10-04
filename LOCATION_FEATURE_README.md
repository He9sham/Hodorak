# Location-Based Check In/Check Out Feature

This document describes the implementation of the location-based check in/check out feature for the Hodorak Flutter app.

## Overview

The feature allows administrators to set a workplace location and ensures that employees can only check in/out when they are within a specified radius of the workplace.

## Features

### Admin Features
- **Set Workplace Location**: Admins can select a location on Google Maps and set an allowed radius (10-500 meters)
- **Location Management**: Admins can save, update, or clear the workplace location
- **Visual Feedback**: The map shows the selected location with a circle indicating the allowed radius

### Employee Features
- **Location Validation**: Check in/out is only allowed when the employee is within the allowed radius
- **Real-time Location Status**: The Geo Location widget shows current location status
- **Distance Display**: Shows the distance to the workplace location
- **Error Messages**: Clear error messages when location validation fails

## Technical Implementation

### Dependencies Added
- `google_maps_flutter: ^2.6.1` - For map display and location selection
- `geolocator: ^12.0.0` - For GPS location services and distance calculations

### Key Components

#### Models
- `WorkplaceLocation` - Represents the saved workplace location with coordinates, name, and allowed radius
- `UserLocation` - Represents the current user's GPS location

#### Services
- `LocationService` - Handles GPS location retrieval, distance calculations, and location storage
- Uses SharedPreferences for local storage of workplace location

#### Providers
- `workplaceLocationProvider` - Manages workplace location state
- `userLocationProvider` - Manages current user location state
- `locationValidationProvider` - Handles location validation logic

#### Screens
- `AdminLocationScreen` - Admin interface for setting workplace location
- Updated `UserHomeScreen` - Shows real-time location status
- Updated `AttendanceButtons` - Includes location validation in check in/out

### Permissions

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to verify you are at the workplace for check-in/check-out.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to verify you are at the workplace for check-in/check-out.</string>
```

### Google Maps Configuration

#### Android
Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

#### iOS
Add your Google Maps API key to `ios/Runner/AppDelegate.swift` (if needed).

## Usage

### For Administrators
1. Navigate to Admin Home Screen
2. Tap "Workplace Location" card
3. Select location on the map by tapping
4. Enter a location name
5. Adjust the allowed radius using the slider
6. Tap "Save Location"

### For Employees
1. The Geo Location widget automatically shows your current location status
2. Tap the refresh button to update location status
3. Check in/out will only work if you're within the allowed radius
4. Error messages will appear if you're outside the allowed area

## Error Handling

- **No Workplace Location Set**: Shows warning message
- **Location Permission Denied**: Prompts user to enable location permissions
- **GPS Unavailable**: Shows error message and prevents check in/out
- **Outside Allowed Radius**: Shows distance and prevents check in/out

## Security Considerations

- Location data is stored locally using SharedPreferences
- GPS accuracy is set to high for precise location detection
- Location validation happens in real-time during check in/out
- Biometric authentication is still required in addition to location validation

## Future Enhancements

- Multiple workplace locations support
- Time-based location restrictions
- Location history tracking
- Offline location caching
- Integration with backend location services
