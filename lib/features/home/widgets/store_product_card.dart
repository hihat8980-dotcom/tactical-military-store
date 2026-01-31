import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/features/cart/cart_provider.dart';

class StoreProductCard extends StatelessWidget {
  final Product product;

  const StoreProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return FutureBuilder<List<String>>(
      future: service.getProductImagesUrls(product.id),
      builder: (context, snapshot) {
        final images = snapshot.data ?? [product.imageUrl];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // =====================================================
              // ✅ IMAGE SECTION (Auto Expand)
              // =====================================================
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),

                    // ❤️ Favorite Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.favorite_border,
                            size: 17,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, "/favorites");
                          },
                        ),
                      ),
                    ),

                    // 🔥 Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "الأكثر مبيعًا",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // ✅ FIXED INFO HEIGHT (Never Overflow)
              // =====================================================
              SizedBox(
                height: 72,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Price + Cart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${product.price.toStringAsFixed(0)} YER",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              context.read<CartProvider>().addToCart(
                                    product: product,
                                    size: "Default",
                                    quantity: 1,
                                  );
                            },
                            child: Container(
                              height: 28,
                              width: 28,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
