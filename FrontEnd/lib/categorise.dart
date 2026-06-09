import 'package:flutter/material.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final void Function(String?) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final all = [null, ...categories.map((c) => c as String?)];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = all[i];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: isSelected
                  ? HomeScreenStyles.selectedChipOf(context)
                  : HomeScreenStyles.unselectedChipOf(context),
              child: Text(
                cat ?? 'All',
                style: isSelected
                    ? HomeScreenStyles.chipSelectedOf(context)
                    : HomeScreenStyles.chipUnselectedOf(context),
              ),
            ),
          );
        },
      ),
    );
  }
}
