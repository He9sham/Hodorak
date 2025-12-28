import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/shift.dart';
import 'package:hodorak/core/models/supabase_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository(Supabase.instance.client);
});

class ShiftRepository {
  final SupabaseClient _supabase;

  ShiftRepository(this._supabase);

  Future<String?> getCompanyId(String userId) async {
    final response = await _supabase
        .from('users')
        .select('company_id')
        .eq('id', userId)
        .single();
    return response['company_id'] as String?;
  }

  Future<List<Shift>> getCompanyShifts(String companyId) async {
    final response = await _supabase
        .from('shifts')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('name');

    return (response as List).map((e) => Shift.fromJson(e)).toList();
  }

  Future<List<SupabaseUser>> getCompanyEmployees(String companyId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('company_id', companyId)
        .order('name');

    return (response as List).map((e) => SupabaseUser.fromJson(e)).toList();
  }

  Future<void> addShift(Shift shift) async {
    await _supabase.from('shifts').insert(shift.toInsertJson());
  }

  Future<void> assignEmployeeToShift(String shiftId, String userId) async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Check for existing active assignment
    final existingAssignment = await _supabase
        .from('employee_shifts')
        .select()
        .eq('user_id', userId)
        .lte('effective_from', todayStr)
        .isFilter('effective_to', null)
        .maybeSingle();

    if (existingAssignment != null) {
      // End the current assignment
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr =
          '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      await _supabase
          .from('employee_shifts')
          .update({
            'effective_to': yesterdayStr,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existingAssignment['id']);
    }

    // Create new assignment
    await _supabase.from('employee_shifts').insert({
      'user_id': userId,
      'shift_id': shiftId,
      'effective_from': todayStr,
      'effective_to': null,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getEmployeeShiftForDate(
    String userId,
    DateTime date,
  ) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Call Supabase RPC function to get employee shift for date
    final response = await _supabase.rpc(
      'get_employee_shift_for_date',
      params: {'p_user_id': userId, 'p_date': dateStr},
    );

    if (response == null || (response is List && response.isEmpty)) {
      return null;
    }

    return response is List ? response.first : response;
  }
}
