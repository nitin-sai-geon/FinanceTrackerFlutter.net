import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/categorise.dart';
import 'package:finance_tracker/add_transactions.dart';
import 'package:finance_tracker/comparisionModal.dart';
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
    if (selectedCategory == null) return transactions;
    return transactions
        .where((t) => t['category'] == selectedCategory)
        .toList();
  }

  void _onTransactionDismissed(Map<String, dynamic> transaction) {
    ref.read(transactionsProvider.notifier).removeTransaction(transaction);
    ScaffoldMessenger.of(context).clearSnackBars();
    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${transaction['description']} deleted'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(transactionsProvider.notifier).addTransaction(transaction);
          },
        ),
      ),
    );
    controller.closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        ref
            .read(transactionsProvider.notifier)
            .deleteTransactionApi(transaction);
      }
    });
  }

  void _loadForPeriod() {
    final period = ref.read(selectedPeriodProvider);
    ref
        .read(transactionsProvider.notifier)
        .loadTransactions(month: period.month, year: period.year);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadForPeriod);
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(selectedPeriodProvider);
    final transactions = ref.watch(transactionsProvider);
    final isLoading = ref.watch(transactionsLoadingProvider);
    final errorMsg = ref.watch(transactionsErrorProvider);
    final filtered = filteredTransactions(transactions);

    return Scaffold(
      backgroundColor: HomeScreenStyles.background,
      appBar: AppBar(
        backgroundColor: HomeScreenStyles.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              color: HomeScreenStyles.primary,
              size: 26,
            ),
            const SizedBox(width: 8),
            const Text('Finance Tracker', style: HomeScreenStyles.appBarTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: HomeScreenStyles.onBackground,
            ),
            onPressed: () {},
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
        backgroundColor: HomeScreenStyles.primary,
        foregroundColor: HomeScreenStyles.onPrimary,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add),
        label: const Text('ADD TRANSACTION', style: HomeScreenStyles.fabLabel),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const LinearProgressIndicator(color: HomeScreenStyles.primary),
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 12),
                MonthYearPicker(
                  selectedMonth: period.month,
                  selectedYear: period.year,
                  onMonthChanged: (v) {
                    ref.read(selectedPeriodProvider.notifier).setMonth(v);
                    _loadForPeriod();
                  },
                  onYearChanged: (v) {
                    ref.read(selectedPeriodProvider.notifier).setYear(v);
                    _loadForPeriod();
                  },
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const ComparisonModal(),
                    );
                  },
                  style: HomeScreenStyles.analyticsButtonStyle,
                  icon: const Icon(
                    Icons.analytics_outlined,
                    color: HomeScreenStyles.secondary,
                    size: 20,
                  ),
                  label: const Text(
                    'VIEW INCOME VS EXPENSE',
                    style: HomeScreenStyles.analyticsButtonLabel,
                  ),
                ),
                const SizedBox(height: 24),
                CategoryFilter(
                  categories: uniqueCategories(transactions),
                  selectedCategory: selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => selectedCategory = category);
                  },
                ),
                const SizedBox(height: 24),
                if (isLoading && filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: CircularProgressIndicator(
                        color: HomeScreenStyles.primary,
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
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
