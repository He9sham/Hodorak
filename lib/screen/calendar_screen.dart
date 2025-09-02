import 'package:flutter/material.dart';
import 'package:hodorak/models/daily_attendance_summary.dart';
import 'package:hodorak/services/calendar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService calendarService = CalendarService();
  List<DailyAttendanceSummary> summaries = [];
  bool loading = true;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() => loading = true);
    try {
      final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
      final loadedSummaries = await calendarService.getSummariesInRange(
        startDate,
        endDate,
      );
      setState(() => summaries = loadedSummaries);
    } catch (e) {
      _showError('Failed to load calendar data: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Month',
    );

    if (picked != null) {
      setState(() => selectedMonth = picked);
      _loadSummaries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        actions: [
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            tooltip: 'Export Data',
          ),
          IconButton(
            onPressed: _selectMonth,
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Select Month',
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedMonth = DateTime(
                            selectedMonth.year,
                            selectedMonth.month - 1,
                          );
                        });
                        _loadSummaries();
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed:
                          selectedMonth.month < DateTime.now().month ||
                              selectedMonth.year < DateTime.now().year
                          ? () {
                              setState(() {
                                selectedMonth = DateTime(
                                  selectedMonth.year,
                                  selectedMonth.month + 1,
                                );
                              });
                              _loadSummaries();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary stats
          if (summaries.isNotEmpty) _buildMonthSummary(),

          // Calendar grid
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : summaries.isEmpty
                ? _buildEmptyState()
                : _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary() {
    final totalDays = summaries.length;
    final totalPresent = summaries.fold(
      0,
      (sum, s) => sum + s.presentEmployees,
    );
    final totalAbsent = summaries.fold(0, (sum, s) => sum + s.absentEmployees);
    final avgPercentage =
        summaries.fold(0.0, (sum, s) => sum + s.attendancePercentage) /
        totalDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Days', totalDays.toString(), Icons.calendar_today),
          _buildStatItem(
            'Present',
            totalPresent.toString(),
            Icons.check_circle,
          ),
          _buildStatItem('Absent', totalAbsent.toString(), Icons.cancel),
          _buildStatItem(
            'Avg %',
            '${avgPercentage.toStringAsFixed(1)}%',
            Icons.percent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No attendance data for ${_getMonthName(selectedMonth.month)} ${selectedMonth.year}',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'End a day in the attendance screen to save data here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getAttendanceColor(
                summary.attendancePercentage,
              ),
              child: Text(
                summary.date.day.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${_getDayName(summary.date.weekday)} ${summary.date.day}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${summary.presentEmployees}/${summary.totalEmployees} present (${summary.attendancePercentage.toStringAsFixed(1)}%)',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(
                          'Present',
                          summary.presentEmployees,
                          Colors.green,
                        ),
                        _buildDetailItem(
                          'Absent',
                          summary.absentEmployees,
                          Colors.red,
                        ),
                        _buildDetailItem(
                          'Total',
                          summary.totalEmployees,
                          Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Employee Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...summary.employeeAttendances.map(
                      (emp) => _buildEmployeeItem(emp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  Widget _buildEmployeeItem(EmployeeAttendance emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emp.isPresent ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: emp.isPresent ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            emp.isPresent ? Icons.check_circle : Icons.cancel,
            color: emp.isPresent ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp.employeeName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (emp.checkIn != null)
                  Text(
                    'In: ${_formatTime(emp.checkIn!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                if (emp.checkOut != null)
                  Text(
                    'Out: ${_formatTime(emp.checkOut!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                if (emp.workingHours != null)
                  Text(
                    'Hours: ${_formatDuration(emp.workingHours!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> _exportData() async {
    try {
      final data = await calendarService.exportData();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy the following JSON data to save your attendance records:',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  data,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Failed to export data: $e');
    }
  }
}
