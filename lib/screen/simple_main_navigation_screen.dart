import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/odoo/odoo_service.dart';
import 'package:hodorak/screen/attendance_screen.dart';
import 'package:hodorak/screen/calendar_screen.dart';
import 'package:hodorak/providers/navigation_provider.dart';

class SimpleMainNavigationScreen extends ConsumerWidget {
  final OdooService odooService;

  const SimpleMainNavigationScreen({super.key, required this.odooService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);
    final screens = [
      AttendancePage(odoo: odooService),
      const CalendarScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: navigationState.currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationState.currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).setCurrentIndex(index);
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
