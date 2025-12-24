import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerButton extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime) onDateRangeSelected;

  const DateRangePickerButton({
    required this.onDateRangeSelected,
    this.startDate,
    this.endDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return OutlinedButton.icon(
      onPressed: () => _showDateRangePicker(context),
      icon: const Icon(Icons.date_range),
      label: Text(
        startDate != null && endDate != null
            ? '${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}'
            : 'Select Custom Range',
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: startDate ?? now.subtract(const Duration(days: 7)),
      end: endDate ?? now,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }
}
