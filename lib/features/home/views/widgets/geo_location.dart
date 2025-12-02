import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/providers/company_location_provider.dart';
import 'package:hodorak/core/utils/logger.dart';

class GeoLocation extends ConsumerWidget {
  const GeoLocation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationValidationState = ref.watch(locationValidationProvider);
    final companyLocationState = ref.watch(companyLocationProvider);

    return Container(
      height: 100.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Color.fromARGB(237, 225, 225, 228),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: -4,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Text(
              'Geo Location',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
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
            bottom: 12.h,
            left: 16.w,
            right: 16.w,
            child: _buildLocationStatus(
              locationValidationState,
              companyLocationState,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus(
    LocationValidationState locationState,
    CompanyLocationState companyState,
  ) {
    // Debug print to help identify the issue
    Logger.info('Location State Debug:');
    Logger.info('  - isLoading: ${locationState.isLoading}');
    Logger.info('  - isAtWorkplace: ${locationState.isAtWorkplace}');
    Logger.info(
      '  - distanceToWorkplace: ${locationState.distanceToWorkplace}',
    );
    Logger.info('  - errorMessage: ${locationState.errorMessage}');
    Logger.info(
      '  - hasWorkplaceLocation: ${locationState.hasWorkplaceLocation}',
    );
    Logger.info('Company Location State Debug:');
    Logger.info('  - location: ${companyState.location}');
    Logger.info('  - isLoading: ${companyState.isLoading}');
    Logger.info('  - error: ${companyState.error}');
    Logger.info('  - hasLocation: ${companyState.hasLocation}');

    if (locationState.isLoading) {
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
    if (locationState.isAtWorkplace) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: Image.asset('assets/Icon_true.png'),
          ),
          horizontalSpace(10),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: Colors.grey[500],
                        ),
                        horizontalSpace(4),
                        Text(
                          'Distance: ${locationState.distanceToWorkplace!.toInt()}m',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: Image.asset('assets/Icon_False.png'),
          ),
          horizontalSpace(10),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: Colors.grey[500],
                        ),
                        horizontalSpace(4),
                        Text(
                          'Distance: ${locationState.distanceToWorkplace!.toInt()}m',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                if (locationState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      locationState.errorMessage!,
                      style: TextStyle(fontSize: 12.sp, color: Colors.red),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
