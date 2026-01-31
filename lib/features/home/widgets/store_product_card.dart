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
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ صورة أقصر
              SizedBox(
                height: 115,
                width: double.infinity,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),

              // ✅ معلومات مضغوطة جدًا
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الاسم
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

                    // السعر + زر السلة
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

                        // زر سلة صغير واحترافي
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
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 5,
                                  color:
                                      Colors.black.withValues(alpha: 0.18),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 16,
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
