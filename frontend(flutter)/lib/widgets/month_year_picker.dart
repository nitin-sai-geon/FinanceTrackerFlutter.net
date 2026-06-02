import 'package:flutter/material.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';

class MonthYearPicker extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  const MonthYearPicker({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final years = List.generate(5, (i) => DateTime.now().year - i);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(child: _PeriodDropdown<int>(
            label: 'MONTH',
            value: selectedMonth,
            items: List.generate(12, (i) => i + 1).map((m) =>
                DropdownMenuItem(value: m, child: Text(_monthNames[m - 1]))).toList(),
            onChanged: (v) { if (v != null) onMonthChanged(v); },
          )),
          const SizedBox(width: 16),
          Expanded(child: _PeriodDropdown<int>(
            label: 'YEAR',
            value: selectedYear,
            items: years.map((y) =>
                DropdownMenuItem(value: y, child: Text('$y'))).toList(),
            onChanged: (v) { if (v != null) onYearChanged(v); },
          )),
        ],
      ),
    );
  }
}

class _PeriodDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _PeriodDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HomeScreenStyles.fieldLabel),
        const SizedBox(height: 4),
        DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: Container(height: 1, color: HomeScreenStyles.borderSubtle),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: HomeScreenStyles.onBackground,
          ),
          dropdownColor: HomeScreenStyles.background,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
