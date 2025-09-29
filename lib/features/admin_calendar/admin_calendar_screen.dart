import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/features/admin_calendar/providers/admin_calendar_provider.dart';
import 'package:hodorak/features/admin_calendar/widgets/admin_calendar_widget.dart';
import 'package:hodorak/features/admin_calendar/widgets/attendance_summary_widget.dart';
import 'package:hodorak/features/admin_calendar/widgets/filter_widgets.dart';
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
      ref.read(adminCalendarProvider.notifier).selectDay(DateTime.now());
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    ref.read(adminCalendarProvider.notifier).selectDay(selectedDay);
    ref.read(adminCalendarProvider.notifier).changeFocusedDay(focusedDay);
  }

  void _onPageChanged(DateTime focusedDay) {
    ref.read(adminCalendarProvider.notifier).changeFocusedDay(focusedDay);
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  void _applyDateFilter(DateTime? date) {
    ref.read(adminCalendarProvider.notifier).setFilterDate(date);
  }

  void _applyUserFilter(String? userId) {
    ref.read(adminCalendarProvider.notifier).setFilterUserId(userId);
  }

  void _clearFilters() {
    ref.read(adminCalendarProvider.notifier).clearFilters();
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
    final adminState = ref.watch(adminCalendarProvider);
    final selectedSummary = ref
        .read(adminCalendarProvider.notifier)
        .getSelectedDaySummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Calendar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(adminCalendarProvider.notifier).loadAttendanceData(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Filters
              FilterWidgets(
                employees: adminState.employees,
                selectedDate: adminState.filterDate,
                selectedUserId: adminState.filterUserId,
                onDateChanged: _applyDateFilter,
                onUserChanged: _applyUserFilter,
                onClearFilters: _clearFilters,
              ),

              // Calendar
              SizedBox(
                height: 310.h, // Controlled calendar size
                child: AdminCalendarWidget(
                  calendarFormat: _calendarFormat,
                  focusedDay: adminState.focusedDay,
                  selectedDay: adminState.selectedDay,
                  events: adminState.events,
                  isLoading: adminState.isLoading,
                  errorMessage: adminState.errorMessage,
                  onDaySelected: _onDaySelected,
                  onPageChanged: _onPageChanged,
                  onFormatChanged: _onFormatChanged,
                ),
              ),

              // Summary - No scrolling, just content
              if (selectedSummary != null)
                AttendanceSummaryWidget(
                  summary: selectedSummary,
                  onUserTap: (employeeAttendance) => _navigateToUserDetail(
                    employeeAttendance,
                    selectedSummary.date,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
