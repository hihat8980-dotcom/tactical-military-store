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
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.07),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // =====================================================
              // ✅ IMAGE (Flexible)
              // =====================================================
              Expanded(
                child: Stack(
                  children: [
                    // صور المنتج
                    snapshot.connectionState == ConnectionState.waiting
                        ? const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : PageView.builder(
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
                        child: Icon(
                          Icons.favorite_border,
                          size: 17,
                          color: Colors.redAccent,
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
                          borderRadius: BorderRadius.circular(10),
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
              // ✅ INFO SECTION (Small + No Overflow)
              // =====================================================
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // اسم المنتج
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // السعر
                        Text(
                          "${product.price.toStringAsFixed(0)} YER",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        // 🛒 Cart Button
                        InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            context.read<CartProvider>().addToCart(
                                  product: product,
                                  size: "Default",
                                  quantity: 1,
                                );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(
                                  "🛒 تمت إضافة ${product.name}",
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00C853),
                                  Color(0xFF009624),
                                ],
                              ),
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
            ],
          ),
        );
      },
    );
  }
}
