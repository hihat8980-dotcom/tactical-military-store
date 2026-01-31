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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,

        // ✅ أفضل Ratio يخلي الكرت قصير واحترافي
        childAspectRatio: 1.15,
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
