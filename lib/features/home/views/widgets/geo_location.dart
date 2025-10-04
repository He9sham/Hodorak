import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/location_provider.dart';

class GeoLocation extends ConsumerWidget {
  const GeoLocation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationValidationState = ref.watch(locationValidationProvider);
    final workplaceLocationState = ref.watch(workplaceLocationProvider);

    return Stack(
      children: [
        Container(
          height: 260.h,
          width: 343.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color.fromARGB(237, 225, 225, 228),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Text(
            'Geo Location',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: IconButton(
            icon: Icon(Icons.refresh, size: 20.sp),
            onPressed: () {
              ref.read(locationValidationProvider.notifier).validateLocation();
            },
            tooltip: 'Refresh location',
          ),
        ),

        Positioned(
          top: 50,
          right: 30,
          child: Container(
            width: 300.w,
            height: 160.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Image.asset('assets/Frame_location.png'),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: _buildLocationStatus(
            locationValidationState,
            workplaceLocationState,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStatus(
    LocationValidationState locationState,
    WorkplaceLocationState workplaceState,
  ) {
    if (locationState.isValidating) {
      return Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          horizontalSpace(8),
          Text(
            'Checking location...',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
        ],
      );
    }

    if (workplaceState.location == null) {
      return Row(
        children: [
          Image.asset('assets/Icon_False.png'),
          horizontalSpace(8),
          Expanded(
            child: Text(
              'No workplace location set by admin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      );
    }

    if (locationState.isAtWorkplace) {
      return Row(
        children: [
          Image.asset('assets/Icon_true.png'),
          horizontalSpace(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are inside the allowed zone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                if (locationState.distanceToWorkplace != null)
                  Text(
                    'Distance: ${locationState.distanceToWorkplace!.toInt()}m',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Image.asset('assets/Icon_False.png'),
          horizontalSpace(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are outside the allowed zone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.red,
                  ),
                ),
                if (locationState.distanceToWorkplace != null)
                  Text(
                    'Distance: ${locationState.distanceToWorkplace!.toInt()}m',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                if (locationState.errorMessage != null)
                  Text(
                    locationState.errorMessage!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
