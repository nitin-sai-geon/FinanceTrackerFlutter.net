import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/categorise.dart';
import 'package:finance_tracker/add_transactions.dart';
import 'package:finance_tracker/comparison_modal.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/provider/date_provider.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';
import 'package:finance_tracker/widgets/month_year_picker.dart';
import 'package:finance_tracker/widgets/transaction_tile.dart';
import 'package:finance_tracker/widgets/edit_transaction.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? selectedCategory;
  DateTimeRange? _dateFilter;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(transactionsProvider.notifier).loadMoreTransactions();
    }
  }

  List<String> uniqueCategories(List<Map<String, dynamic>> transactions) {
    return transactions
        .map((t) => t['category']?.toString() ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> filteredTransactions(
    List<Map<String, dynamic>> transactions,
  ) {
    var result = transactions;
    if (selectedCategory != null) {
      result = result.where((t) => t['category'] == selectedCategory).toList();
    }
    if (_dateFilter != null) {
      final end = _dateFilter!.end.add(const Duration(days: 1));
      result = result.where((t) {
        final d = t['date'];
        if (d is! DateTime) return true;
        return !d.isBefore(_dateFilter!.start) && d.isBefore(end);
      }).toList();
    }
    return result;
  }

  Future<void> _openDateFilter() async {
    if (_dateFilter != null) {
      final clear = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Date Filter'),
          content: const Text('Change or clear the active date filter?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Change'),
            ),
          ],
        ),
      );
      if (clear == true) {
        setState(() => _dateFilter = null);
        _loadForPeriod();
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
        child: Theme(data: HomeScreenStyles.datePickerTheme(context), child: child!),
      ),
    );
    if (range != null && mounted) {
      setState(() => _dateFilter = range);
      _load();
    }
  }

  void _onTransactionDismissed(Map<String, dynamic> transaction) {
    ref.read(transactionsProvider.notifier).removeTransaction(transaction);
    bool undone = false;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text('${transaction['description']} deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undone = true;
            ref.read(transactionsProvider.notifier).addTransaction(transaction);
          },
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 4500), () async {
      if (undone || !mounted) return;
      controller.close();
      try {
        await ref
            .read(transactionsProvider.notifier)
            .deleteTransactionApi(transaction);
      } catch (e) {
        debugPrint('delete failed: $e');
        if (!mounted) return;
        ref.read(transactionsProvider.notifier).addTransaction(transaction);
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to delete transaction')),
        );
      }
    });
  }

  void _loadForPeriod() {
    final period = ref.read(selectedPeriodProvider);
    ref
        .read(transactionsProvider.notifier)
        .loadTransactions(month: period.month, year: period.year);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _load() {
    if (_dateFilter != null) {
      ref.read(transactionsProvider.notifier).loadTransactions(
            fromDate: _fmt(_dateFilter!.start),
            toDate: _fmt(_dateFilter!.end),
          );
    } else {
      _loadForPeriod();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(_loadForPeriod);
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(selectedPeriodProvider);
    final transactions = ref.watch(transactionsProvider);
    final isLoadingMore = ref.watch(transactionsLoadingMoreProvider);
    final isLoading = ref.watch(transactionsLoadingProvider);
    final errorMsg = ref.watch(transactionsErrorProvider);
    final filtered = filteredTransactions(transactions);

    return Scaffold(
      backgroundColor: HomeScreenStyles.bgOf(context),
      appBar: AppBar(
        backgroundColor: HomeScreenStyles.bgOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Text('Reports', style: HomeScreenStyles.appBarTitleOf(context)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bar_chart_outlined,
              color: HomeScreenStyles.onBgOf(context),
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const ComparisonModal(),
            ),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  color: _dateFilter != null
                      ? HomeScreenStyles.primaryOf(context)
                      : HomeScreenStyles.onBgOf(context),
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
            onPressed: _openDateFilter,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddTransactionsScreen(),
          );
        },
        backgroundColor: HomeScreenStyles.primaryOf(context),
        foregroundColor: HomeScreenStyles.onPrimaryOf(context),
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add),
        label: const Text(
          'ADD TRANSACTION',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            LinearProgressIndicator(color: HomeScreenStyles.primaryOf(context)),
          if (errorMsg != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMsg,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                MonthYearPicker(
                  selectedMonth: period.month,
                  selectedYear: period.year,
                  onMonthChanged: (v) {
                    ref.read(selectedPeriodProvider.notifier).setMonth(v);
                    setState(() => _dateFilter = null);
                    _loadForPeriod();
                  },
                  onYearChanged: (v) {
                    ref.read(selectedPeriodProvider.notifier).setYear(v);
                    setState(() => _dateFilter = null);
                    _loadForPeriod();
                  },
                ),
                const SizedBox(height: 16),
                CategoryFilter(
                  categories: uniqueCategories(transactions),
                  selectedCategory: selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => selectedCategory = category);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                if (isLoading && filtered.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: CircularProgressIndicator(
                        color: HomeScreenStyles.primaryOf(context),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (t) => TransactionTile(
                      key: ValueKey(t['id'] ?? t),
                      transaction: t,
                      onDismissed: () => _onTransactionDismissed(t),
                      onEdit: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) =>
                            EditTransactionScreen(transaction: t),
                      ),
                    ),
                  ),
                if (isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: HomeScreenStyles.primaryOf(context),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
