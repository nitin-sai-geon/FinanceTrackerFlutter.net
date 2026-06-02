import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/provider/date_provider.dart';

class ComparisonModal extends ConsumerWidget {
  const ComparisonModal({super.key});

  static const List<Color> _chartColors = [
    Colors.red, Colors.orange, Colors.blue, Colors.teal,
    Colors.pink, Colors.amber, Colors.purple, Colors.cyan,
  ];

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final allTransactions = ref.watch(transactionsProvider);

    final transactions = allTransactions.where((t) {
      final rawDate = t['date'];
      DateTime? date;
      if (rawDate is DateTime) {
        date = rawDate;
      } else if (rawDate is String) {
        date = DateTime.tryParse(rawDate);
      }
      if (date == null) return false;
      return date.month == period.month && date.year == period.year;
    }).toList();

    final totalIncome = transactions
        .where((t) => (t['categoryType'] as int? ?? 1) == 0)
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

    final Map<String, double> expenseTotals = {};
    for (final t in transactions) {
      final category = t['category']?.toString() ?? '';
      final categoryType = t['categoryType'] as int? ?? 1;
      if (categoryType == 0 || category.isEmpty) continue;
      expenseTotals[category] =
          (expenseTotals[category] ?? 0) + (t['amount'] as num).toDouble();
    }

    final totalExpenses = expenseTotals.values.fold(0.0, (sum, v) => sum + v);
    final entries = expenseTotals.entries.toList();
    final availableHeight = MediaQuery.of(context).size.height * 0.75;

    return SafeArea(
      child: SizedBox(
        height: availableHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Spending by Category — ${_monthNames[period.month - 1]} ${period.year}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Income',
                      amount: totalIncome,
                      color: Colors.green,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Expenses',
                      amount: totalExpenses,
                      color: Colors.red,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          'No data for ${_monthNames[period.month - 1]} ${period.year}',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 60,
                          sections: entries.asMap().entries.map((entry) {
                            final index = entry.key;
                            final amount = entry.value.value;
                            return PieChartSectionData(
                              value: amount,
                              color: _chartColors[index % _chartColors.length],
                              title: '',
                              radius: 80,
                            );
                          }).toList(),
                        ),
                      ),
              ),
              if (entries.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value.key;
                    final amount = entry.value.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle,
                            color: _chartColors[index % _chartColors.length],
                            size: 10),
                        const SizedBox(width: 4),
                        Text(
                          '$category: ₹${amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
