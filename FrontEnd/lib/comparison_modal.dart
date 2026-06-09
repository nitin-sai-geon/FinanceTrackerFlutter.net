import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';
import 'package:finance_tracker/utils/report_pdf.dart';

class ComparisonModal extends ConsumerStatefulWidget {
  const ComparisonModal({super.key});

  @override
  ConsumerState<ComparisonModal> createState() => _ComparisonModalState();
}

class _ComparisonModalState extends ConsumerState<ComparisonModal> {
  late int _month;
  late int _year;
  DateTimeRange? _dateFilter;
  bool _includeFullMonthIncome = false;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  static const _chartColors = [
    Colors.red,
    Colors.orange,
    Colors.blue,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.cyan,
  ];

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
    Future.microtask(_load);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    String? fromDate, toDate;
    if (_dateFilter != null) {
      final fetchFrom = _includeFullMonthIncome
          ? DateTime(_dateFilter!.start.year, _dateFilter!.start.month, 1)
          : _dateFilter!.start;
      fromDate = _fmt(fetchFrom);
      toDate = _fmt(_dateFilter!.end);
    }

    final data = await ref
        .read(transactionsProvider.notifier)
        .fetchRange(
          month: _dateFilter == null ? _month : null,
          year: _dateFilter == null ? _year : null,
          fromDate: fromDate,
          toDate: toDate,
        );
    if (mounted) {
      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    }
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year--;
      } else {
        _month--;
      }
    });
    _load();
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_year == now.year && _month == now.month) return;
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year++;
      } else {
        _month++;
      }
    });
    _load();
  }

  Future<void> _openDateFilter() async {
    if (_dateFilter != null) {
      final clear = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: HomeScreenStyles.bgOf(ctx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Date Filter',
              style: TextStyle(color: HomeScreenStyles.onBgOf(ctx))),
          content: Text('Change or clear the active date filter?',
              style: TextStyle(color: HomeScreenStyles.secondaryOf(ctx))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Change',
                  style: TextStyle(color: HomeScreenStyles.primaryOf(ctx))),
            ),
          ],
        ),
      );
      if (clear == true) {
        setState(() {
          _dateFilter = null;
          _includeFullMonthIncome = false;
        });
        _load();
        return;
      }
      if (clear == null) return;
    }

    if (!mounted) return;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateFilter,
      builder: (context, child) => Localizations.override(
        context: context,
        locale: const Locale('en', 'GB'),
        child: Theme(
          data: HomeScreenStyles.datePickerTheme(context),
          child: child!,
        ),
      ),
    );
    if (range != null && mounted) {
      setState(() => _dateFilter = range);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _transactions
        .where((t) => (t['categoryType'] as int? ?? 1) == 0)
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

    final Map<String, double> expenseTotals = {};
    for (final t in _transactions) {
      final category = t['category']?.toString() ?? '';
      if ((t['categoryType'] as int? ?? 1) == 0 || category.isEmpty) continue;
      if (_includeFullMonthIncome && _dateFilter != null) {
        final d = t['date'];
        if (d is DateTime && d.isBefore(_dateFilter!.start)) continue;
      }
      expenseTotals[category] =
          (expenseTotals[category] ?? 0) + (t['amount'] as num).toDouble();
    }

    final totalExpenses = expenseTotals.values.fold(0.0, (sum, v) => sum + v);
    final entries = expenseTotals.entries.toList();
    final availableHeight = MediaQuery.of(context).size.height * 0.75;
    final now = DateTime.now();
    final atCurrentMonth = _year == now.year && _month == now.month;

    final String title = _dateFilter != null
        ? '${_fmtDisplay(_dateFilter!.start)} — ${_fmtDisplay(_dateFilter!.end)}'
        : '${_monthNames[_month - 1]} $_year';

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
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: HomeScreenStyles.borderOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  if (_dateFilter == null)
                    IconButton(
                      icon: Icon(Icons.chevron_left,
                          color: HomeScreenStyles.onBgOf(context)),
                      onPressed: _prevMonth,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (_dateFilter == null) const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: HomeScreenStyles.onBgOf(context),
                      ),
                      textAlign: _dateFilter != null
                          ? TextAlign.center
                          : TextAlign.left,
                    ),
                  ),
                  if (_dateFilter == null) const SizedBox(width: 4),
                  if (_dateFilter == null)
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: atCurrentMonth
                            ? HomeScreenStyles.mutedOf(context)
                            : HomeScreenStyles.onBgOf(context),
                      ),
                      onPressed: atCurrentMonth ? null : _nextMonth,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.filter_alt_outlined,
                          size: 22,
                          color: _dateFilter != null
                              ? HomeScreenStyles.primaryOf(context)
                              : HomeScreenStyles.secondaryOf(context),
                        ),
                        onPressed: _openDateFilter,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      if (_dateFilter != null)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 22,
                      color: HomeScreenStyles.secondaryOf(context),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => printReport(
                            title: title,
                            totalIncome: totalIncome,
                            totalExpenses: totalExpenses,
                            entries: entries,
                            generatedOn: _fmtDisplay(DateTime.now()),
                          ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (_dateFilter != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Include full month income',
                        style: TextStyle(
                          fontSize: 13,
                          color: HomeScreenStyles.secondaryOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _includeFullMonthIncome,
                      onChanged: (v) {
                        setState(() => _includeFullMonthIncome = v);
                        _load();
                      },
                      activeThumbColor: HomeScreenStyles.primaryOf(context),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              if (_isLoading)
                LinearProgressIndicator(
                    color: HomeScreenStyles.primaryOf(context))
              else
                const SizedBox(height: 4),
              const SizedBox(height: 12),
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
                child: _isLoading && entries.isEmpty
                    ? const SizedBox.shrink()
                    : entries.isEmpty
                    ? Center(
                        child: Text(
                          'No expense data for $title',
                          style: TextStyle(
                              color: HomeScreenStyles.mutedOf(context)),
                        ),
                      )
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 60,
                          sections: entries.asMap().entries.map((e) {
                            return PieChartSectionData(
                              value: e.value.value,
                              color: _chartColors[e.key % _chartColors.length],
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
                  children: entries.asMap().entries.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          color: _chartColors[e.key % _chartColors.length],
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${e.value.key}: ₹${e.value.value.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: HomeScreenStyles.onBgOf(context),
                          ),
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
                  color: HomeScreenStyles.secondaryOf(context),
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
