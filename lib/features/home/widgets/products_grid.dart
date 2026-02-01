import 'package:flutter/material.dart';
import 'package:tactical_military_store/models/product.dart';
import 'store_product_card.dart';

class ProductsGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onTap;

  const ProductsGrid({
    super.key,
    required this.products,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // =====================================================
    // ✅ Responsive Grid Settings
    // =====================================================

    // عدد الأعمدة تلقائي حسب الشاشة
    int crossAxisCount = 2;

    if (width > 900) {
      crossAxisCount = 4; // Web Large
    } else if (width > 650) {
      crossAxisCount = 3; // Tablet
    }

    // Aspect Ratio تلقائي يعطي كرت Premium بدون Overflow
    double aspectRatio = 0.72;

    if (width > 900) {
      aspectRatio = 0.85;
    } else if (width > 650) {
      aspectRatio = 0.78;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,

        // ✅ Auto Responsive Ratio
        childAspectRatio: aspectRatio,
      ),

      itemBuilder: (context, index) {
        final product = products[index];

        return GestureDetector(
          onTap: () => onTap(product),
          child: StoreProductCard(
            key: ValueKey(product.id),
            product: product,
          ),
        );
      },
    );
  }
}
