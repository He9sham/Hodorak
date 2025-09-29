import 'package:flutter/material.dart';
import 'package:hodorak/core/helper/spacing.dart';

class FilterWidgets extends StatelessWidget {
  final List<Map<String, dynamic>> employees;
  final DateTime? selectedDate;
  final String? selectedUserId;
  final Function(DateTime?) onDateChanged;
  final Function(String?) onUserChanged;
  final VoidCallback onClearFilters;

  const FilterWidgets({
    super.key,
    required this.employees,
    required this.selectedDate,
    required this.selectedUserId,
    required this.onDateChanged,
    required this.onUserChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const Spacer(),
              if (selectedDate != null || selectedUserId != null)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
                ),
            ],
          ),
          verticalSpace(12),

          Row(
            children: [
              // Date filter
              Expanded(child: _buildDateFilter(context)),
              horizontalSpace(12),

              // User filter
              Expanded(child: _buildUserFilter(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Date',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        verticalSpace(4),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                horizontalSpace(8),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),
                ),
                if (selectedDate != null)
                  GestureDetector(
                    onTap: () => onDateChanged(null),
                    child: Icon(Icons.clear, size: 16, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Employee',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        verticalSpace(4),
        DropdownButtonFormField<String>(
          initialValue: selectedUserId,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            prefixIcon: Icon(Icons.person, size: 16, color: Colors.grey[600]),
          ),
          hint: Text('Select employee'),
          items: [
            DropdownMenuItem<String>(value: null, child: Text('All Employees')),
            ...employees.map(
              (employee) => DropdownMenuItem<String>(
                value: employee['id'].toString(),
                child: Text(employee['name'] ?? 'Unknown'),
              ),
            ),
          ],
          onChanged: onUserChanged,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
