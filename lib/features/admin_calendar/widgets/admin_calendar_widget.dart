import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hodorak/core/helper/spacing.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminCalendarWidget extends StatelessWidget {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<DailyAttendanceSummary>> events;
  final bool isLoading;
  final String? errorMessage;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;

  const AdminCalendarWidget({
    super.key,
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    required this.isLoading,
    required this.errorMessage,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            verticalSpace(16),
            Text('Loading attendance data...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red[300]),
            verticalSpace(16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            verticalSpace(8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            verticalSpace(16),
            ElevatedButton(
              onPressed: () {
                // Trigger refresh - this would need to be passed from parent
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return TableCalendar<DailyAttendanceSummary>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,
      eventLoader: (day) => events[day] ?? [],
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        defaultDecoration: BoxDecoration(shape: BoxShape.circle),
        weekendDecoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        formatButtonTextStyle: TextStyle(color: Colors.white),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
      ),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) {
            return null;
          }

          final summary = events.first;
          final presentCount = summary.presentEmployees;

          return Container(
            margin: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Present employees indicator
                if (presentCount > 0)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (presentCount > 0 && summary.absentEmployees > 0)
                  verticalSpace(2),
                // Absent employees indicator
                if (summary.absentEmployees > 0)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
        defaultBuilder: (context, day, focusedDay) {
          final dayEvents = events[day] ?? [];
          if (dayEvents.isEmpty) {
            return null;
          }

          final summary = dayEvents.first;
          final attendancePercentage = summary.attendancePercentage;

          Color? backgroundColor;
          if (attendancePercentage >= 80) {
            backgroundColor = Colors.green[50];
          } else if (attendancePercentage >= 50) {
            backgroundColor = Colors.orange[50];
          } else {
            backgroundColor = Colors.red[50];
          }

          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
