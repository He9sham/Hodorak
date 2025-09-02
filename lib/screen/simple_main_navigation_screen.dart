import 'package:flutter/material.dart';
import 'package:hodorak/odoo/odoo_service.dart';
import 'package:hodorak/screen/attendance_screen.dart';
import 'package:hodorak/screen/calendar_screen.dart';

class SimpleMainNavigationScreen extends StatefulWidget {
  final OdooService odooService;

  const SimpleMainNavigationScreen({super.key, required this.odooService});

  @override
  State<SimpleMainNavigationScreen> createState() =>
      _SimpleMainNavigationScreenState();
}

class _SimpleMainNavigationScreenState
    extends State<SimpleMainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AttendancePage(odoo: widget.odooService),
      const CalendarScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
