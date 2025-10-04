import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/models/daily_attendance_summary.dart';
import 'package:hodorak/core/providers/calendar_provider.dart';
import 'package:hodorak/core/utils/logger.dart';
import 'package:hodorak/features/calender_screen/utils/utils.dart';
import 'package:hodorak/features/calender_screen/view/widgets/widgets.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<DailyAttendanceSummary>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = CalendarDateUtils.getToday();
    _loadEvents();
  }

  void _loadEvents() {
    final calendarState = ref.read(enhancedCalendarProvider);
    CalendarHelpers.clearEvents(_events);

    Logger.debug(
      'CalendarScreen: Loading events - Found ${calendarState.summaries.length} summaries',
    );
    Logger.debug(
      'CalendarScreen: Calendar state - loading: ${calendarState.isLoading}, error: ${calendarState.errorMessage}',
    );

    for (final summary in calendarState.summaries) {
      Logger.debug(
        'CalendarScreen: Adding summary for ${summary.date.toString()} - ${summary.presentEmployees}/${summary.totalEmployees} present',
      );
      CalendarHelpers.addAttendanceToEvents(_events, summary);
    }

    Logger.info('CalendarScreen: Total events loaded: ${_events.length}');

    // Force a rebuild to show the events
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshData() async {
    try {
      final notifier = ref.read(enhancedCalendarProvider.notifier);
      await notifier.refreshMonthData();
      _loadEvents();
    } catch (e) {
      // Handle refresh errors gracefully
      Logger.error('Could not refresh data: $e');
    }
  }

  Future<void> _loadLiveDataForDate(DateTime date) async {
    try {
      // First check if we already have data for this date
      if (CalendarHelpers.hasAttendanceData(_events, date)) {
        Logger.debug('CalendarScreen: Using existing data for $date');
        return;
      }

      // Try to get live data
      final notifier = ref.read(enhancedCalendarProvider.notifier);
      final summary = await notifier.getAttendanceForDate(date);
      if (summary != null) {
        setState(() {
          CalendarHelpers.addAttendanceToEvents(_events, summary);
        });
        Logger.info(
          'CalendarScreen: Live data loaded for $date: ${summary.presentEmployees}/${summary.totalEmployees} present',
        );
      } else {
        Logger.info(
          'CalendarScreen: No live data available for $date - user did not attend on this day',
        );
        // Don't create test summaries - only show days with actual attendance
      }
    } catch (e) {
      // Silently handle errors - fallback to existing data
      Logger.error('CalendarScreen: Could not load live data for date: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(enhancedCalendarProvider);

    // Reload events when calendar state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (calendarState.summaries.isNotEmpty && _events.isEmpty) {
        _loadEvents();
      }
    });

    // Show error if present
    if (calendarState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CalendarHelpers.showError(context, calendarState.errorMessage!);
        ref.read(enhancedCalendarProvider.notifier).clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar<DailyAttendanceSummary>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) => _events[day] ?? [],
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Colors.green,
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
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!CalendarDateUtils.isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                // Load live data for the selected date
                _loadLiveDataForDate(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              // Refresh data when month changes
              if (focusedDay.month != _selectedDay?.month ||
                  focusedDay.year != _selectedDay?.year) {
                ref
                    .read(enhancedCalendarProvider.notifier)
                    .selectMonth(focusedDay);
                _loadEvents();
              }
            },
            selectedDayPredicate: (day) {
              return CalendarDateUtils.isSameDay(_selectedDay, day);
            },
          ),

          // Selected day details
          if (_selectedDay != null)
            CalendarHeader(
              selectedDay: _selectedDay!,
              recordCount: CalendarHelpers.getRecordCountForDate(
                _events,
                _selectedDay!,
              ),
            ),

          // Event list
          Expanded(
            child: calendarState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedDay != null
                ? EventList(
                    events: CalendarHelpers.getAttendanceDataForDate(
                      _events,
                      _selectedDay!,
                    ),
                    day: _selectedDay!,
                  )
                : const EmptyState(),
          ),
        ],
      ),
    );
  }
}
