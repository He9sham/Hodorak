import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/providers/supabase_calendar_provider.dart';
import 'package:hodorak/features/admin_calendar/widgets/admin_calendar_widget.dart';
import 'package:hodorak/features/admin_calendar/widgets/user_attendance_detail_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminCalendarScreen extends ConsumerStatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  ConsumerState<AdminCalendarScreen> createState() =>
      _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends ConsumerState<AdminCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Set today as selected day by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supabaseCalendarProvider.notifier).selectMonth(DateTime.now());
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Note: SupabaseCalendarNotifier only supports month selection
    // Individual day selection would need to be implemented
  }

  void _onPageChanged(DateTime focusedDay) {
    // Note: SupabaseCalendarNotifier doesn't support focusedDay tracking
    // This would need to be implemented if required
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  void _applyDateFilter(DateTime? date) {
    // Note: SupabaseCalendarNotifier doesn't support date filtering
    // This would need to be implemented if required
  }

  void _applyUserFilter(String? userId) {
    // Note: SupabaseCalendarNotifier doesn't support user filtering
    // This would need to be implemented if required
  }

  void _clearFilters() {
    // Note: SupabaseCalendarNotifier doesn't support filtering
    // This would need to be implemented if required
  }

  void _navigateToUserDetail(
    EmployeeAttendance employeeAttendance,
    DateTime date,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserAttendanceDetailScreen(
          employeeAttendance: employeeAttendance,
          date: date,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(supabaseCalendarProvider);
    // Note: SupabaseCalendarNotifier doesn't have getSelectedDaySummary method
    // This would need to be implemented if required

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Calendar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(supabaseCalendarProvider.notifier).loadSummaries(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Filters - Note: SupabaseCalendarState doesn't have these properties
              // FilterWidgets would need to be adapted or removed
              // FilterWidgets(
              //   employees: adminState.employees,
              //   selectedDate: adminState.filterDate,
              //   selectedUserId: adminState.filterUserId,
              //   onDateChanged: _applyDateFilter,
              //   onUserChanged: _applyUserFilter,
              //   onClearFilters: _clearFilters,
              // ),

              // Calendar
              SizedBox(
                height: 310.h, // Controlled calendar size
                child: AdminCalendarWidget(
                  calendarFormat: _calendarFormat,
                  focusedDay: adminState.selectedMonth,
                  selectedDay:
                      null, // SupabaseCalendarState doesn't track selected day
                  events: {}, // SupabaseCalendarState doesn't have events map
                  isLoading: adminState.isLoading,
                  errorMessage: adminState.errorMessage,
                  onDaySelected: _onDaySelected,
                  onPageChanged: _onPageChanged,
                  onFormatChanged: _onFormatChanged,
                ),
              ),

              // Summary - Note: selectedSummary is not available
              // This would need to be implemented based on SupabaseCalendarState
              // if (selectedSummary != null)
              //   AttendanceSummaryWidget(
              //     summary: selectedSummary,
              //     onUserTap: (employeeAttendance) => _navigateToUserDetail(
              //       employeeAttendance,
              //       selectedSummary.date,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
