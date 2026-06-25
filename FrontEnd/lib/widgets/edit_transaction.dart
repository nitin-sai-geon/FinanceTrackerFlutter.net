import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:finance_tracker/URLs/urls.dart';
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
  bool _isUploading = false;
  String? _attachmentPath;

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
    _attachmentPath = t['attachmentPath']?.toString();
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

  Future<void> _uploadAttachment() async {
    final id = widget.transaction['id']?.toString();
    if (id == null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final rawBytes = await picked.readAsBytes();
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) throw Exception('Could not decode image');
      final pngBytes = Uint8List.fromList(img.encodePng(decoded));
      final path = await ref
          .read(transactionsProvider.notifier)
          .uploadAttachment(
            id,
            pngBytes,
            '${picked.name.split('.').first}.png',
          );
      if (!mounted) return;
      setState(() => _attachmentPath = path);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Attachment uploaded')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
                color: HomeScreenStyles.borderOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Edit Transaction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HomeScreenStyles.onBgOf(context),
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
          Text('CATEGORY', style: HomeScreenStyles.fieldLabelOf(context)),
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: selectedCategoryId,
            isExpanded: true,
            underline: Container(
              height: 1,
              color: HomeScreenStyles.borderOf(context),
            ),
            style: HomeScreenStyles.formInputStyleOf(context),
            dropdownColor: HomeScreenStyles.bgOf(context),
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
                onPressed: _pickDate,
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: HomeScreenStyles.secondaryOf(context),
                ),
                label: Text(
                  'Change',
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
          if (_attachmentPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ApiUrls.attachmentUrl(_attachmentPath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 160,
                  color: HomeScreenStyles.surfaceOf(context),
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: HomeScreenStyles.mutedOf(context),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextButton.icon(
            onPressed: _isUploading ? null : _uploadAttachment,
            icon: _isUploading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.attach_file,
                    size: 16,
                    color: HomeScreenStyles.secondaryOf(context),
                  ),
            label: Text(
              _isUploading ? 'Uploading…' : 'Attach Receipt',
              style: TextStyle(
                color: HomeScreenStyles.secondaryOf(context),
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: HomeScreenStyles.formSaveButtonStyleOf(context),
              child: _isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
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
        Text(label, style: HomeScreenStyles.fieldLabelOf(context)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: HomeScreenStyles.formInputStyleOf(context),
          decoration: InputDecoration(
            enabledBorder: HomeScreenStyles.formInputBorderOf(context),
            focusedBorder: HomeScreenStyles.formFocusedBorderOf(context),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}
