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
        // ⏳ تحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        // ❌ لا يوجد مقاسات أصلاً
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(); // المنتج بدون مقاس → لا يظهر شيء
        }

        final variants = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ عنوان احترافي
              const Text(
                "📏 اختر المقاس",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // ✅ Chips احترافية
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: variants.map((v) {
                  final isSelected = selectedSize == v.size;

                  return ChoiceChip(
                    label: Text(
                      v.size,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey.shade200,
                    elevation: 2,
                    pressElevation: 5,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    // ✅ عند الاختيار
                    onSelected: (_) {
                      onSelected(v.size);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              // ✅ تنبيه بسيط لو لم يختار
              if (selectedSize == null)
                Text(
                  "يمكنك المتابعة بدون اختيار مقاس إذا لم يكن مطلوبًا.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
