import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/features/cart/cart_provider.dart';

class StoreProductCard extends StatefulWidget {
  final Product product;

  const StoreProductCard({
    super.key,
    required this.product,
  });

  @override
  State<StoreProductCard> createState() => _StoreProductCardState();
}

class _StoreProductCardState extends State<StoreProductCard> {
  int _activeIndex = 0;

  // ================= IMAGE BUILDER =================
  Widget _buildProductImage(List<String> images) {
    if (images.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      );
    }

    if (images.length == 1) {
      return Image.network(
        images.first,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    }

    return PageView.builder(
      itemCount: images.length,
      onPageChanged: (i) => setState(() => _activeIndex = i),
      itemBuilder: (_, i) {
        return Image.network(
          images[i],
          width: double.infinity,
          fit: BoxFit.contain,
        );
      },
    );
  }

  // ================= INDICATOR =================
  Widget _buildIndicator(List<String> images) {
    if (images.length <= 1) return const SizedBox();

    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          images.length,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 6,
            width: _activeIndex == i ? 14 : 6,
            decoration: BoxDecoration(
              color: _activeIndex == i
                  ? Colors.black
                  : Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return FutureBuilder<List<String>>(
      future: service.getProductImagesUrls(widget.product.id),
      builder: (context, snapshot) {
        final images = List<String>.from(snapshot.data ?? []);

        if (images.isEmpty && widget.product.imageUrl.isNotEmpty) {
          images.add(widget.product.imageUrl);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * 0.74;
            final infoHeight = constraints.maxHeight * 0.26;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // ================= IMAGE =================
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      children: [
                        _buildProductImage(images),
                        _buildIndicator(images),
                      ],
                    ),
                  ),

                  // ================= INFO =================
                  SizedBox(
                    height: infoHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${widget.product.price.toStringAsFixed(0)} YER",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B8F3A), // أخضر أنيق
                                ),
                              ),

                              // 🛒 ADD TO CART BUTTON (TACTICAL GREEN)
                              InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () {
                                  context.read<CartProvider>().addToCart(
                                        product: widget.product,
                                        size: "Default",
                                        quantity: 1,
                                      );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("✅ تمت الإضافة إلى السلة"),
                                      duration: Duration(milliseconds: 800),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00C853), // أخضر أساسي
                                        Color(0xFF1B8F3A), // أخضر داكن
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                        color: const Color(0xFF00C853)
                                            .withValues(alpha: 0.45),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 18,
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
      },
    );
  }
}
