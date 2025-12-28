import 'package:hodorak/core/models/employee_shift.dart';
import 'package:hodorak/core/models/shift.dart';
import 'package:hodorak/core/supabase/supabase_service.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing work shifts and employee shift assignments
///
/// This service handles:
/// - CRUD operations for shifts
/// - Employee shift assignments
/// - Querying active shifts for employees
class SupabaseShiftService {
  final SupabaseClient _client = SupabaseService.client;

  // Table names
  static const String _shiftsTable = 'shifts';
  static const String _employeeShiftsTable = 'employee_shifts';

  // =====================================================
  // SHIFT MANAGEMENT
  // =====================================================

  /// Get all shifts for a company
  Future<List<Shift>> getCompanyShifts(String companyId) async {
    try {
      Logger.debug(
        'SupabaseShiftService: Fetching shifts for company $companyId',
      );

      final data = await _client
          .from(_shiftsTable)
          .select()
          .eq('company_id', companyId)
          .eq('is_active', true)
          .order('name', ascending: true);

      final shifts = (data as List)
          .map((record) => Shift.fromJson(record))
          .toList();

      Logger.info(
        'SupabaseShiftService: Found ${shifts.length} shifts for company $companyId',
      );
      return shifts;
    } catch (e) {
      Logger.error('SupabaseShiftService: Error fetching company shifts: $e');
      rethrow;
    }
  }

  /// Get a specific shift by ID
  Future<Shift?> getShiftById(String shiftId) async {
    try {
      Logger.debug('SupabaseShiftService: Fetching shift $shiftId');

      final data = await _client
          .from(_shiftsTable)
          .select()
          .eq('id', shiftId)
          .maybeSingle();

      if (data == null) {
        Logger.info('SupabaseShiftService: Shift $shiftId not found');
        return null;
      }

      return Shift.fromJson(data);
    } catch (e) {
      Logger.error('SupabaseShiftService: Error fetching shift: $e');
      rethrow;
    }
  }

  /// Create a new shift (admin only)
  Future<Shift> createShift({
    required String companyId,
    required String name,
    required String startTime, // Format: "HH:MM:SS"
    required String endTime, // Format: "HH:MM:SS"
    required int gracePeriodMinutes,
    required bool isOvernight,
  }) async {
    try {
      Logger.debug(
        'SupabaseShiftService: Creating shift "$name" for company $companyId',
      );

      final shiftData = {
        'company_id': companyId,
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
        'grace_period_minutes': gracePeriodMinutes,
        'is_overnight': isOvernight,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(_shiftsTable)
          .insert(shiftData)
          .select()
          .single();

      Logger.info('SupabaseShiftService: Shift "$name" created successfully');
      return Shift.fromJson(response);
    } catch (e) {
      Logger.error('SupabaseShiftService: Error creating shift: $e');
      rethrow;
    }
  }

  /// Update an existing shift (admin only)
  Future<Shift> updateShift({
    required String shiftId,
    String? name,
    String? startTime,
    String? endTime,
    int? gracePeriodMinutes,
    bool? isOvernight,
    bool? isActive,
  }) async {
    try {
      Logger.debug('SupabaseShiftService: Updating shift $shiftId');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (startTime != null) updateData['start_time'] = startTime;
      if (endTime != null) updateData['end_time'] = endTime;
      if (gracePeriodMinutes != null)
        updateData['grace_period_minutes'] = gracePeriodMinutes;
      if (isOvernight != null) updateData['is_overnight'] = isOvernight;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await _client
          .from(_shiftsTable)
          .update(updateData)
          .eq('id', shiftId)
          .select()
          .single();

      Logger.info('SupabaseShiftService: Shift $shiftId updated successfully');
      return Shift.fromJson(response);
    } catch (e) {
      Logger.error('SupabaseShiftService: Error updating shift: $e');
      rethrow;
    }
  }

  /// Soft delete a shift (admin only)
  /// Sets is_active to false instead of deleting the record
  Future<void> deleteShift(String shiftId) async {
    try {
      Logger.debug('SupabaseShiftService: Deleting shift $shiftId');

      await _client
          .from(_shiftsTable)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', shiftId);

      Logger.info('SupabaseShiftService: Shift $shiftId deleted (soft delete)');
    } catch (e) {
      Logger.error('SupabaseShiftService: Error deleting shift: $e');
      rethrow;
    }
  }

  // =====================================================
  // EMPLOYEE SHIFT ASSIGNMENTS
  // =====================================================

  /// Get the current active shift for an employee
  Future<Shift?> getEmployeeCurrentShift(String userId) async {
    try {
      Logger.debug(
        'SupabaseShiftService: Fetching current shift for user $userId',
      );

      final today = DateTime.now();
      final todayDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final data = await _client
          .from(_employeeShiftsTable)
          .select('*, shifts(*)')
          .eq('user_id', userId)
          .lte('effective_from', todayDate)
          .or('effective_to.is.null,effective_to.gte.$todayDate')
          .maybeSingle();

      if (data == null) {
        Logger.info(
          'SupabaseShiftService: No active shift found for user $userId',
        );
        return null;
      }

      final employeeShift = EmployeeShift.fromJson(data);
      return employeeShift.shift;
    } catch (e) {
      Logger.error(
        'SupabaseShiftService: Error fetching employee current shift: $e',
      );
      rethrow;
    }
  }

  /// Get employee's shift for a specific date
  Future<Shift?> getEmployeeShiftForDate(String userId, DateTime date) async {
    try {
      Logger.debug(
        'SupabaseShiftService: Fetching shift for user $userId on $date',
      );

      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final data = await _client
          .from(_employeeShiftsTable)
          .select('*, shifts(*)')
          .eq('user_id', userId)
          .lte('effective_from', dateStr)
          .or('effective_to.is.null,effective_to.gte.$dateStr')
          .maybeSingle();

      if (data == null) {
        Logger.info(
          'SupabaseShiftService: No shift found for user $userId on $date',
        );
        return null;
      }

      final employeeShift = EmployeeShift.fromJson(data);
      return employeeShift.shift;
    } catch (e) {
      Logger.error(
        'SupabaseShiftService: Error fetching employee shift for date: $e',
      );
      rethrow;
    }
  }

  /// Get all shift assignments for an employee (history)
  Future<List<EmployeeShift>> getEmployeeShiftHistory(String userId) async {
    try {
      Logger.debug(
        'SupabaseShiftService: Fetching shift history for user $userId',
      );

      final data = await _client
          .from(_employeeShiftsTable)
          .select('*, shifts(*)')
          .eq('user_id', userId)
          .order('effective_from', ascending: false);

      final assignments = (data as List)
          .map((record) => EmployeeShift.fromJson(record))
          .toList();

      Logger.info(
        'SupabaseShiftService: Found ${assignments.length} shift assignments for user $userId',
      );
      return assignments;
    } catch (e) {
      Logger.error(
        'SupabaseShiftService: Error fetching employee shift history: $e',
      );
      rethrow;
    }
  }

  /// Assign an employee to a shift (admin only)
  Future<EmployeeShift> assignEmployeeToShift({
    required String userId,
    required String shiftId,
    required DateTime effectiveFrom,
    DateTime? effectiveTo,
  }) async {
    try {
      Logger.debug(
        'SupabaseShiftService: Assigning user $userId to shift $shiftId',
      );

      // End any current active shift assignments for this employee
      await _endCurrentShiftAssignment(userId, effectiveFrom);

      final assignmentData = {
        'user_id': userId,
        'shift_id': shiftId,
        'effective_from':
            '${effectiveFrom.year}-${effectiveFrom.month.toString().padLeft(2, '0')}-${effectiveFrom.day.toString().padLeft(2, '0')}',
        'effective_to': effectiveTo != null
            ? '${effectiveTo.year}-${effectiveTo.month.toString().padLeft(2, '0')}-${effectiveTo.day.toString().padLeft(2, '0')}'
            : null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from(_employeeShiftsTable)
          .insert(assignmentData)
          .select('*, shifts(*)')
          .single();

      Logger.info(
        'SupabaseShiftService: User $userId assigned to shift $shiftId',
      );
      return EmployeeShift.fromJson(response);
    } catch (e) {
      Logger.error(
        'SupabaseShiftService: Error assigning employee to shift: $e',
      );
      rethrow;
    }
  }

  /// End the current shift assignment for an employee
  /// This is called internally when assigning a new shift
  Future<void> _endCurrentShiftAssignment(
    String userId,
    DateTime endDate,
  ) async {
    try {
      final today = DateTime.now();
      final todayDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Find current active assignment
      final currentAssignment = await _client
          .from(_employeeShiftsTable)
          .select()
          .eq('user_id', userId)
          .lte('effective_from', todayDate)
          .isFilter('effective_to', null)
          .maybeSingle();

      if (currentAssignment != null) {
        // Set effective_to to one day before the new assignment starts
        final endDateStr =
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${(endDate.day - 1).toString().padLeft(2, '0')}';

        await _client
            .from(_employeeShiftsTable)
            .update({
              'effective_to': endDateStr,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', currentAssignment['id']);

        Logger.debug(
          'SupabaseShiftService: Ended current shift assignment for user $userId',
        );
      }
    } catch (e) {
      Logger.error(
        'SupabaseShiftService: Error ending current shift assignment: $e',
      );
      // Don't rethrow - this is an internal helper method
    }
  }

  /// Unassign an employee from a shift (admin only)
  /// Sets effective_to to today
  Future<void> unassignEmployeeFromShift(String employeeShiftId) async {
    try {
      Logger.debug(
        'SupabaseShiftService: Unassigning employee shift $employeeShiftId',
      );

      final today = DateTime.now();
      final todayDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _client
          .from(_employeeShiftsTable)
          .update({
            'effective_to': todayDate,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', employeeShiftId);

      Logger.info(
        'SupabaseShiftService: Employee shift $employeeShiftId unassigned',
      );
    } catch (e) {
      Logger.error(
        'SupabaseShiftService: Error unassigning employee from shift: $e',
      );
      rethrow;
    }
  }

  /// Get all employees assigned to a specific shift (admin only)
  Future<List<EmployeeShift>> getShiftEmployees(String shiftId) async {
    try {
      Logger.debug(
        'SupabaseShiftService: Fetching employees for shift $shiftId',
      );

      final today = DateTime.now();
      final todayDate =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final data = await _client
          .from(_employeeShiftsTable)
          .select('*, users(id, name, email)')
          .eq('shift_id', shiftId)
          .lte('effective_from', todayDate)
          .or('effective_to.is.null,effective_to.gte.$todayDate')
          .order('effective_from', ascending: false);

      final assignments = (data as List)
          .map((record) => EmployeeShift.fromJson(record))
          .toList();

      Logger.info(
        'SupabaseShiftService: Found ${assignments.length} employees for shift $shiftId',
      );
      return assignments;
    } catch (e) {
      Logger.error('SupabaseShiftService: Error fetching shift employees: $e');
      rethrow;
    }
  }

  // =====================================================
  // UTILITY METHODS
  // =====================================================

  /// Check if a user has an active shift assignment
  Future<bool> hasActiveShift(String userId) async {
    try {
      final shift = await getEmployeeCurrentShift(userId);
      return shift != null;
    } catch (e) {
      Logger.error('SupabaseShiftService: Error checking active shift: $e');
      return false;
    }
  }
}
