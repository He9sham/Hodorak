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

    return Container(
      height: 100.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color.fromARGB(237, 225, 225, 228),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              'Geo Location',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            top: 5.h,
            right: 5.w,
            child: IconButton(
              icon: Icon(Icons.refresh, size: 20.sp),
              onPressed: () {
                ref
                    .read(locationValidationProvider.notifier)
                    .validateLocation();
              },
              tooltip: 'Refresh location',
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: 20.w,
            right: 20.w,
            child: _buildLocationStatus(
              locationValidationState,
              workplaceLocationState,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus(
    LocationValidationState locationState,
    WorkplaceLocationState workplaceState,
  ) {
    if (locationState.isValidating) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          horizontalSpace(8),
          Flexible(
            child: Text(
              'Checking location...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (workplaceState.location == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/Icon_False.png'),
          horizontalSpace(8),
          Flexible(
            child: Text(
              'No workplace location set by admin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Colors.orange,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (locationState.isAtWorkplace) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/Icon_true.png'),
          horizontalSpace(8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You are inside the allowed zone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (locationState.distanceToWorkplace != null)
                  Text(
                    'Distance: ${locationState.distanceToWorkplace!.toInt()}m',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/Icon_False.png'),
          horizontalSpace(8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You are outside the allowed zone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.red,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (locationState.distanceToWorkplace != null)
                  Text(
                    'Distance: ${locationState.distanceToWorkplace!.toInt()}m',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (locationState.errorMessage != null)
                  Text(
                    locationState.errorMessage!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
