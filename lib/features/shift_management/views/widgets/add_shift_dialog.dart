import 'package:flutter/material.dart';

class AddShiftDialog extends StatefulWidget {
  final Future<bool> Function({
    required String name,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int gracePeriodMinutes,
    required bool isOvernight,
  })
  onAdd;

  const AddShiftDialog({super.key, required this.onAdd});

  @override
  State<AddShiftDialog> createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<AddShiftDialog> {
  final _nameController = TextEditingController();
  final _startTimeController = TextEditingController(text: '09:00:00');
  final _endTimeController = TextEditingController(text: '17:00:00');
  final _graceController = TextEditingController(text: '15');
  bool _isOvernight = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter shift name')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final startTime = _parseTime(_startTimeController.text);
      final endTime = _parseTime(_endTimeController.text);
      final grace = int.tryParse(_graceController.text) ?? 15;

      final success = await widget.onAdd(
        name: _nameController.text,
        startTime: startTime,
        endTime: endTime,
        gracePeriodMinutes: grace,
        isOvernight: _isOvernight,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shift "${_nameController.text}" added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid time format'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Shift'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Shift Name',
                hintText: 'e.g., Morning Shift',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _startTimeController,
              decoration: const InputDecoration(
                labelText: 'Start Time (HH:MM:SS)',
                hintText: '09:00:00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _endTimeController,
              decoration: const InputDecoration(
                labelText: 'End Time (HH:MM:SS)',
                hintText: '17:00:00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _graceController,
              decoration: const InputDecoration(
                labelText: 'Grace Period (minutes)',
                hintText: '15',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Overnight Shift'),
              subtitle: const Text('Shift spans across midnight'),
              value: _isOvernight,
              onChanged: (value) {
                setState(() => _isOvernight = value ?? false);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Shift'),
        ),
      ],
    );
  }
}
