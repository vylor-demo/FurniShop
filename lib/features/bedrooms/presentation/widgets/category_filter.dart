import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BedroomCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const BedroomCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
            ),
          ),
          ...categories.map((category) {
            final formatted = category
                .split('_')
                .map((chunk) =>
                    chunk.isEmpty ? chunk : '${chunk[0].toUpperCase()}${chunk.substring(1)}')
                .join(' ');
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(formatted),
                selected: selectedCategory == category,
                selectedColor: AppColors.accent.withValues(alpha: 0.15),
                onSelected: (_) => onCategorySelected(category),
              ),
            );
          }),
        ],
      ),
    );
  }
}
