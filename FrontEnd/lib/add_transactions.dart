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
  final _newCategoryController = TextEditingController();
  String? selectedCategoryId;
  DateTime? selectedDate;
  int _newCategoryType = 1;
  bool _isCreatingCategory = false;

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
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;
    try {
      final created = await ref
          .read(categoriesProvider.notifier)
          .createCategory(name, _newCategoryType);
      _newCategoryController.clear();
      setState(() {
        selectedCategoryId = created['id']?.toString();
        _isCreatingCategory = false;
      });
    } catch (e) {
      debugPrint('createCategory error: $e');
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: HomeScreenStyles.datePickerTheme(context),
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
        selectedDate == null) {
      return;
    }

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
                  color: HomeScreenStyles.borderOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: HomeScreenStyles.onBgOf(context),
              ),
            ),
            const SizedBox(height: 24),
            Text('DESCRIPTION', style: HomeScreenStyles.fieldLabelOf(context)),
            const SizedBox(height: 4),
            TextField(
              controller: _descriptionController,
              style: HomeScreenStyles.formInputStyleOf(context),
              decoration: InputDecoration(
                hintText: 'e.g. Lunch, Salary',
                hintStyle: TextStyle(color: HomeScreenStyles.mutedOf(context)),
                enabledBorder: HomeScreenStyles.formInputBorderOf(context),
                focusedBorder: HomeScreenStyles.formFocusedBorderOf(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            Text('AMOUNT', style: HomeScreenStyles.fieldLabelOf(context)),
            const SizedBox(height: 4),
            TextField(
              controller: _amountController,
              style: HomeScreenStyles.formInputStyleOf(context),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: HomeScreenStyles.mutedOf(context)),
                enabledBorder: HomeScreenStyles.formInputBorderOf(context),
                focusedBorder: HomeScreenStyles.formFocusedBorderOf(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            Text('CATEGORY', style: HomeScreenStyles.fieldLabelOf(context)),
            const SizedBox(height: 4),
            DropdownButton<String>(
              value: selectedCategoryId,
              hint: Text(
                'Select Category',
                style: TextStyle(color: HomeScreenStyles.mutedOf(context)),
              ),
              isExpanded: true,
              underline: Container(
                height: 1,
                color: HomeScreenStyles.borderOf(context),
              ),
              style: HomeScreenStyles.formInputStyleOf(context),
              dropdownColor: HomeScreenStyles.bgOf(context),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id']?.toString() ?? '',
                  child: Text(category['name']?.toString() ?? ''),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategoryId = value),
            ),
            const SizedBox(height: 8),
            if (_isCreatingCategory) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCategoryController,
                      style: HomeScreenStyles.formInputStyleOf(context),
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Category name',
                        hintStyle: TextStyle(
                          color: HomeScreenStyles.mutedOf(context),
                        ),
                        enabledBorder:
                            HomeScreenStyles.formInputBorderOf(context),
                        focusedBorder:
                            HomeScreenStyles.formFocusedBorderOf(context),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _newCategoryType =
                        _newCategoryType == 1 ? 0 : 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: HomeScreenStyles.borderOf(context)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _newCategoryType == 1 ? 'Expense' : 'Income',
                        style: TextStyle(
                          fontSize: 12,
                          color: HomeScreenStyles.secondaryOf(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _createCategory,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: HomeScreenStyles.primaryOf(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 18,
                        color: HomeScreenStyles.mutedOf(context)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        setState(() => _isCreatingCategory = false),
                  ),
                ],
              ),
            ] else
              TextButton.icon(
                onPressed: () =>
                    setState(() => _isCreatingCategory = true),
                icon: Icon(Icons.add,
                    size: 16,
                    color: HomeScreenStyles.secondaryOf(context)),
                label: Text(
                  'New category',
                  style: TextStyle(
                    color: HomeScreenStyles.secondaryOf(context),
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            const SizedBox(height: 20),
            Text('DATE', style: HomeScreenStyles.fieldLabelOf(context)),
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
                        ? HomeScreenStyles.mutedOf(context)
                        : HomeScreenStyles.onBgOf(context),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: pickDate,
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: HomeScreenStyles.secondaryOf(context),
                  ),
                  label: Text(
                    'Pick Date',
                    style: TextStyle(
                      color: HomeScreenStyles.secondaryOf(context),
                      fontSize: 14,
                    ),
                  ),
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
                style: HomeScreenStyles.formSaveButtonStyleOf(context),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
