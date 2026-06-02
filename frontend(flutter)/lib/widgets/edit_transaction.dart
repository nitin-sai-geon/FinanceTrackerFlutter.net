import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  String? selectedCategoryId;
  DateTime? selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _descriptionController = TextEditingController(
      text: t['description']?.toString() ?? '',
    );
    _amountController = TextEditingController(
      text:
          (t['amount'] is double
                  ? t['amount']
                  : (t['amount'] as num).toDouble())
              .toString(),
    );
    selectedCategoryId = t['categoryId']?.toString();
    final rawDate = t['date'];
    selectedDate = rawDate is DateTime
        ? rawDate
        : (rawDate is String ? DateTime.tryParse(rawDate) : null);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) =>
          Theme(data: HomeScreenStyles.datePickerTheme(ctx), child: child!),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _save() async {
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text);
    final id = widget.transaction['id']?.toString();

    if (description.isEmpty ||
        amount == null ||
        selectedCategoryId == null ||
        selectedDate == null ||
        id == null) {
      return;
    }

    setState(() => _isSaving = true);
    await ref.read(transactionsProvider.notifier).updateTransaction(id, {
      'description': description,
      'amount': amount,
      'categoryId': selectedCategoryId,
      'date':
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
    });
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Padding(
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
            'Edit Transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HomeScreenStyles.onBackground,
            ),
          ),
          const SizedBox(height: 24),
          _TransactionField(
            label: 'DESCRIPTION',
            controller: _descriptionController,
          ),
          const SizedBox(height: 20),
          _TransactionField(
            label: 'AMOUNT',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          const Text('CATEGORY', style: HomeScreenStyles.fieldLabel),
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: selectedCategoryId,
            isExpanded: true,
            underline: Container(
              height: 1,
              color: HomeScreenStyles.borderSubtle,
            ),
            style: HomeScreenStyles.formInputStyle,
            dropdownColor: HomeScreenStyles.background,
            items: categories
                .map(
                  (c) => DropdownMenuItem<String>(
                    value: c['id']?.toString() ?? '',
                    child: Text(c['name']?.toString() ?? ''),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => selectedCategoryId = v),
          ),
          const SizedBox(height: 20),
          const Text('DATE', style: HomeScreenStyles.fieldLabel),
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
                onPressed: _pickDate,
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: HomeScreenStyles.secondary,
                ),
                label: const Text(
                  'Change',
                  style: TextStyle(
                    color: HomeScreenStyles.secondary,
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
              onPressed: _isSaving ? null : _save,
              style: HomeScreenStyles.formSaveButtonStyle,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _TransactionField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: HomeScreenStyles.fieldLabel),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: HomeScreenStyles.formInputStyle,
          decoration: const InputDecoration(
            enabledBorder: HomeScreenStyles.formInputBorder,
            focusedBorder: HomeScreenStyles.formFocusedBorder,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}
