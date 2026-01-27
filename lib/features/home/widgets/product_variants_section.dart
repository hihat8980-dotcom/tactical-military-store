import 'package:flutter/material.dart';
import 'package:tactical_military_store/models/product_variant.dart';

class ProductVariantsSection extends StatelessWidget {
  final Future<List<ProductVariant>> variantsFuture;
  final String? selectedSize;
  final ValueChanged<String?> onSelected;

  const ProductVariantsSection({
    super.key,
    required this.variantsFuture,
    required this.selectedSize,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductVariant>>(
      future: variantsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            children: snapshot.data!
                .map(
                  (v) => ChoiceChip(
                    label: Text(v.size),
                    selected: selectedSize == v.size,
                    onSelected: (_) => onSelected(v.size),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
