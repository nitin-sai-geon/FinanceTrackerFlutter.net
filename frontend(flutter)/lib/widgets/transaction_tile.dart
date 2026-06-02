import 'package:flutter/material.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onDismissed;
  final VoidCallback? onEdit;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDismissed,
    required this.onEdit,
  });

  String _formatSubtitle() {
    final category = transaction['category']?.toString() ?? '';
    final d = transaction['date'];
    if (d is DateTime) {
      final dateStr =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      return '$category  •  $dateStr';
    }
    return category;
  }

  String _formatAmount() {
    final amount = transaction['amount'];
    final value = amount is double ? amount : (amount as num).toDouble();
    return '₹${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final category = transaction['category']?.toString() ?? '';
    final categoryType = transaction['categoryType'] as int? ?? 1;
    final icon = HomeScreenStyles.iconForCategory(category, categoryType);

    return Dismissible(
      key: ValueKey(transaction['id'] ?? transaction),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: HomeScreenStyles.iconContainer,
              child: Icon(icon, color: HomeScreenStyles.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['description']?.toString() ?? '',
                    style: HomeScreenStyles.transactionTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatSubtitle(),
                    style: HomeScreenStyles.transactionSubtitle,
                  ),
                ],
              ),
            ),
            Text(_formatAmount(), style: HomeScreenStyles.transactionAmount),
            const SizedBox(width: 8), // ← add
            IconButton(
              // ← add
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: HomeScreenStyles.secondary,
              ),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
