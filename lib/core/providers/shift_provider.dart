import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/employee_shift.dart';
import 'package:hodorak/core/models/shift.dart';
import 'package:hodorak/core/providers/supabase_user_profile_provider.dart';
import 'package:hodorak/core/services/supabase_shift_service.dart';

// =====================================================
// SERVICE PROVIDER
// =====================================================

/// Provider for the SupabaseShiftService
final shiftServiceProvider = Provider<SupabaseShiftService>((ref) {
  return SupabaseShiftService();
});

// =====================================================
// SHIFT PROVIDERS
// =====================================================

/// Provider for fetching all shifts for the current user's company
///
/// This provider automatically disposes when no longer needed.
/// It requires the user to be logged in and have a company_id.
final companyShiftsProvider = FutureProvider.autoDispose<List<Shift>>((
  ref,
) async {
  final shiftService = ref.read(shiftServiceProvider);

  // Get current user from the user profile provider
  final userProfile = ref.watch(supabaseUserProfileProvider);
  final user = userProfile.profileData;

  if (user?.companyId == null) {
    return [];
  }

  return shiftService.getCompanyShifts(user!.companyId!);
});

/// Provider for fetching a specific shift by ID
///
/// Usage: ref.watch(shiftByIdProvider('shift-uuid'))
final shiftByIdProvider = FutureProvider.autoDispose.family<Shift?, String>((
  ref,
  shiftId,
) async {
  final shiftService = ref.read(shiftServiceProvider);
  return shiftService.getShiftById(shiftId);
});

// =====================================================
// EMPLOYEE SHIFT PROVIDERS
// =====================================================

/// Provider for fetching the current user's active shift
///
/// Returns null if the user has no active shift assignment.
final currentUserShiftProvider = FutureProvider.autoDispose<Shift?>((
  ref,
) async {
  final shiftService = ref.read(shiftServiceProvider);

  // Get current user from the user profile provider
  final userProfile = ref.watch(supabaseUserProfileProvider);
  final user = userProfile.profileData;

  if (user?.id == null) {
    return null;
  }

  return shiftService.getEmployeeCurrentShift(user!.id);
});

/// Provider for fetching an employee's shift for a specific date
///
/// Usage: ref.watch(employeeShiftForDateProvider((userId: 'uuid', date: DateTime.now())))
final employeeShiftForDateProvider = FutureProvider.autoDispose
    .family<Shift?, ({String userId, DateTime date})>((ref, params) async {
      final shiftService = ref.read(shiftServiceProvider);
      return shiftService.getEmployeeShiftForDate(params.userId, params.date);
    });

/// Provider for fetching an employee's shift assignment history
///
/// Usage: ref.watch(employeeShiftHistoryProvider('user-uuid'))
final employeeShiftHistoryProvider = FutureProvider.autoDispose
    .family<List<EmployeeShift>, String>((ref, userId) async {
      final shiftService = ref.read(shiftServiceProvider);
      return shiftService.getEmployeeShiftHistory(userId);
    });

/// Provider for fetching all employees assigned to a specific shift
///
/// Usage: ref.watch(shiftEmployeesProvider('shift-uuid'))
/// Admin only - will fail with RLS error if called by non-admin
final shiftEmployeesProvider = FutureProvider.autoDispose
    .family<List<EmployeeShift>, String>((ref, shiftId) async {
      final shiftService = ref.read(shiftServiceProvider);
      return shiftService.getShiftEmployees(shiftId);
    });

// =====================================================
// STATE PROVIDERS FOR FORMS
// =====================================================

// Note: StateProvider declarations are commented out as they're optional
// Uncomment and use them if you need form state management in your admin UI

/*
/// State provider for the selected shift in admin UI
///
/// Used when creating/editing shifts in admin panel.
final selectedShiftProvider = StateProvider.autoDispose<Shift?>((ref) => null);

/// State provider for shift form data
///
/// Used to manage form state when creating a new shift.
final shiftFormProvider = StateProvider.autoDispose<Map<String, dynamic>>(
  (ref) => {
    'name': '',
    'start_time': '09:00:00',
    'end_time': '17:00:00',
    'grace_period_minutes': 15,
    'is_overnight': false,
  },
);
*/

// =====================================================
// COMPUTED PROVIDERS
// =====================================================

/// Provider that checks if the current user has an active shift
///
/// Returns true if user has a shift, false otherwise.
final hasActiveShiftProvider = FutureProvider.autoDispose<bool>((ref) async {
  final shift = await ref.watch(currentUserShiftProvider.future);
  return shift != null;
});

/// Provider for active shifts only (filters out inactive shifts)
final activeShiftsProvider = FutureProvider.autoDispose<List<Shift>>((
  ref,
) async {
  final allShifts = await ref.watch(companyShiftsProvider.future);
  return allShifts.where((shift) => shift.isActive).toList();
});

// =====================================================
// USAGE EXAMPLES
// =====================================================

/*
// Example 1: Display current user's shift in UI
Consumer(
  builder: (context, ref, child) {
    final shiftAsync = ref.watch(currentUserShiftProvider);
    
    return shiftAsync.when(
      data: (shift) {
        if (shift == null) {
          return Text('No shift assigned');
        }
        return Column(
          children: [
            Text('Your Shift: ${shift.name}'),
            Text('Time: ${shift.formattedTimeRange}'),
            Text('Grace Period: ${shift.gracePeriodMinutes} min'),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  },
)

// Example 2: Admin - List all company shifts
Consumer(
  builder: (context, ref, child) {
    final shiftsAsync = ref.watch(companyShiftsProvider);
    
    return shiftsAsync.when(
      data: (shifts) {
        return ListView.builder(
          itemCount: shifts.length,
          itemBuilder: (context, index) {
            final shift = shifts[index];
            return ListTile(
              title: Text(shift.name),
              subtitle: Text(shift.formattedTimeRange),
              trailing: Text('Grace: ${shift.gracePeriodMinutes}m'),
            );
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  },
)

// Example 3: Create a new shift (admin)
Future<void> createShift(WidgetRef ref) async {
  final shiftService = ref.read(shiftServiceProvider);
  final userProfile = ref.read(supabaseUserProfileProvider);
  final user = userProfile.profileData;
  
  try {
    final newShift = await shiftService.createShift(
      companyId: user!.companyId!,
      name: 'Morning Shift',
      startTime: '09:00:00',
      endTime: '17:00:00',
      gracePeriodMinutes: 15,
      isOvernight: false,
    );
    
    // Invalidate the shifts provider to refresh the list
    ref.invalidate(companyShiftsProvider);
    
    print('Shift created: ${newShift.name}');
  } catch (e) {
    print('Error creating shift: $e');
  }
}

// Example 4: Assign employee to shift (admin)
Future<void> assignEmployeeToShift(WidgetRef ref, String userId, String shiftId) async {
  final shiftService = ref.read(shiftServiceProvider);
  
  try {
    final assignment = await shiftService.assignEmployeeToShift(
      userId: userId,
      shiftId: shiftId,
      effectiveFrom: DateTime.now(),
      effectiveTo: null, // null = indefinite
    );
    
    // Invalidate relevant providers
    ref.invalidate(currentUserShiftProvider);
    ref.invalidate(employeeShiftHistoryProvider(userId));
    
    print('Employee assigned to shift');
  } catch (e) {
    print('Error assigning employee: $e');
  }
}

// Example 5: Check if user has active shift before check-in
Future<void> checkIn(WidgetRef ref) async {
  final hasShift = await ref.read(hasActiveShiftProvider.future);
  
  if (!hasShift) {
    // Show warning: "You don't have an assigned shift. Contact your admin."
    return;
  }
  
  // Proceed with check-in...
  final shift = await ref.read(currentUserShiftProvider.future);
  print('Checking in for shift: ${shift?.name}');
}
*/

// =====================================================
// NOTES
// =====================================================

/*
This file uses the existing 'supabaseUserProfileProvider' from your codebase.

The provider returns a SupabaseUserProfileState which contains:
- profileData: SupabaseUser? (with id and companyId fields)
- isLoading: bool
- error: String?

Make sure to initialize the user profile before using shift providers:

Example:
final userProfileNotifier = ref.read(supabaseUserProfileProvider.notifier);
await userProfileNotifier.initializeUserProfile();
*/
