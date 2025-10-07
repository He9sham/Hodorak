import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/providers/supabase_calendar_provider.dart';
import 'package:hodorak/features/admin_calendar/widgets/admin_calendar_widget.dart';
import 'package:hodorak/features/admin_calendar/widgets/attendance_summary_widget.dart';
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
    ref.read(supabaseCalendarProvider.notifier).selectDay(selectedDay);
  }

  void _onPageChanged(DateTime focusedDay) {
    ref.read(supabaseCalendarProvider.notifier).selectMonth(focusedDay);
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
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

    // Create events map for the calendar
    final events = <DateTime, List<DailyAttendanceSummary>>{};
    for (final summary in adminState.summaries) {
      events[summary.date] = [summary];
    }

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
        child: Column(
          children: [
            // Calendar
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: AdminCalendarWidget(
                calendarFormat: _calendarFormat,
                focusedDay: adminState.selectedMonth,
                selectedDay: adminState.selectedDay,
                events: events,
                isLoading: adminState.isLoading,
                errorMessage: adminState.errorMessage,
                onDaySelected: _onDaySelected,
                onPageChanged: _onPageChanged,
                onFormatChanged: _onFormatChanged,
              ),
            ),

            // Attendance Summary for Selected Day
            if (adminState.selectedDaySummary != null)
              Expanded(
                child: SingleChildScrollView(
                  child: AttendanceSummaryWidget(
                    summary: adminState.selectedDaySummary!,
                    onUserTap: (employeeAttendance) => _navigateToUserDetail(
                      employeeAttendance,
                      adminState.selectedDaySummary!.date,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a day to view attendance details',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
