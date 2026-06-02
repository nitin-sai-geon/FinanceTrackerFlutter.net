import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';

class AddTransactionsScreen extends ConsumerStatefulWidget {
  const AddTransactionsScreen({super.key});

  @override
  ConsumerState<AddTransactionsScreen> createState() =>
      _AddTransactionsScreenState();
}

class _AddTransactionsScreenState extends ConsumerState<AddTransactionsScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? selectedCategoryId;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoriesProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: HomeScreenStyles.primary,
            onPrimary: HomeScreenStyles.onPrimary,
            surface: HomeScreenStyles.background,
            onSurface: HomeScreenStyles.onBackground,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> saveTransaction() async {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text);

    if (description.isEmpty ||
        amount == null ||
        selectedCategoryId == null ||
        selectedDate == null) return;

    try {
      await ref.read(transactionsProvider.notifier).postTransaction({
        'description': description,
        'amount': amount,
        'categoryId': selectedCategoryId,
        'date':
            '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Failed to save transaction: $e');
    }
  }

  static const _inputBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: HomeScreenStyles.borderSubtle),
  );

  static const _focusedBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: HomeScreenStyles.primary, width: 1.5),
  );

  static const _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: HomeScreenStyles.secondary,
    letterSpacing: 0.8,
  );

  static const _inputStyle = TextStyle(
    fontSize: 16,
    color: HomeScreenStyles.onBackground,
  );

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: HomeScreenStyles.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: HomeScreenStyles.onBackground,
              ),
            ),
            const SizedBox(height: 24),
            const Text('DESCRIPTION', style: _labelStyle),
            const SizedBox(height: 4),
            TextField(
              controller: _descriptionController,
              style: _inputStyle,
              decoration: const InputDecoration(
                hintText: 'e.g. Lunch, Salary',
                hintStyle: TextStyle(color: HomeScreenStyles.subtitleMuted),
                enabledBorder: _inputBorder,
                focusedBorder: _focusedBorder,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            const Text('AMOUNT', style: _labelStyle),
            const SizedBox(height: 4),
            TextField(
              controller: _amountController,
              style: _inputStyle,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: HomeScreenStyles.subtitleMuted),
                enabledBorder: _inputBorder,
                focusedBorder: _focusedBorder,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            const Text('CATEGORY', style: _labelStyle),
            const SizedBox(height: 4),
            DropdownButton<String>(
              value: selectedCategoryId,
              hint: const Text('Select Category',
                  style: TextStyle(color: HomeScreenStyles.subtitleMuted)),
              isExpanded: true,
              underline:
                  Container(height: 1, color: HomeScreenStyles.borderSubtle),
              style: _inputStyle,
              dropdownColor: HomeScreenStyles.background,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id']?.toString() ?? '',
                  child: Text(category['name']?.toString() ?? ''),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategoryId = value),
            ),
            const SizedBox(height: 20),
            const Text('DATE', style: _labelStyle),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  selectedDate == null
                      ? 'No date selected'
                      : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedDate == null
                        ? HomeScreenStyles.subtitleMuted
                        : HomeScreenStyles.onBackground,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(Icons.calendar_today_outlined,
                      size: 16, color: HomeScreenStyles.secondary),
                  label: const Text('Pick Date',
                      style: TextStyle(
                          color: HomeScreenStyles.secondary, fontSize: 14)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreenStyles.primary,
                  foregroundColor: HomeScreenStyles.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Save',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
