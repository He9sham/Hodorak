import 'package:flutter/material.dart';
import 'package:hodorak/odoo/odoo_service.dart';
import 'package:hodorak/screen/attendance_screen.dart';
import 'package:hodorak/screen/calendar_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final OdooService odooService;

  const MainNavigationScreen({super.key, required this.odooService});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
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
