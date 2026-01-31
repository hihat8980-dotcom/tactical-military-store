import 'package:flutter/material.dart';
import 'package:tactical_military_store/models/category.dart';

class CategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final Function(int?) onSelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        children: [
          _TabItem(
            title: "الكل",
            selected: selectedCategoryId == null,
            onTap: () => onSelected(null),
          ),
          ...categories.map((c) {
            final id = int.parse(c.id);
            return _TabItem(
              title: c.name,
              selected: selectedCategoryId == id,
              onTap: () => onSelected(id),
            );
          }),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                      color: Colors.black.withValues(alpha: 0.15),
                    )
                  ]
                : [],
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
