import 'package:flutter/material.dart';
import 'package:hodorak/features/calender_screen/utils/utils.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime selectedDay;
  final int recordCount;

  const CalendarHeader({
    super.key,
    required this.selectedDay,
    required this.recordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CalendarDateUtils.formatDateForDisplay(selectedDay),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (recordCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$recordCount record(s)',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
