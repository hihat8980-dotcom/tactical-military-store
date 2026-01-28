import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';
import 'package:tactical_military_store/models/product_variant.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/features/cart/cart_provider.dart';

// ✅ استدعاء قسم التعليقات
import 'widgets/product_comments_section.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<List<ProductImage>> _imagesFuture;
  late Future<List<ProductVariant>> _variantsFuture;
  late Future<List<Product>> _sameCategoryFuture;

  String? _selectedSize;
  int _quantity = 1;

  int _currentImage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final service = SupabaseService();

    _imagesFuture = service.getProductImages(widget.product.id);
    _variantsFuture = service.getProductVariants(widget.product.id);
    _sameCategoryFuture =
        service.getProductsByCategory(widget.product.categoryId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ================= ADD TO CART =================
  void _addToCart() {
    context.read<CartProvider>().addToCart(
          product: widget.product,
          size: _selectedSize ?? 'default',
          quantity: _quantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تمت الإضافة إلى السلة")),
    );
  }

  // ================= WHATSAPP =================
  Future<void> _buyViaWhatsApp() async {
    final message =
        "🛒 طلب شراء\n\n"
        "المنتج: ${widget.product.name}\n"
        "المقاس: ${_selectedSize ?? 'بدون'}\n"
        "الكمية: $_quantity\n"
        "السعر: ${widget.product.price.toStringAsFixed(0)} YER\n\n"
        "الصورة:\n${widget.product.imageUrl}";

    final url =
        "https://wa.me/967770004140?text=${Uri.encodeComponent(message)}";

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        centerTitle: true,
      ),

      // ================= ACTION BAR =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _addToCart,
                child: const Text("أضف للسلة"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _buyViaWhatsApp,
                child: const Text("شراء سريع"),
              ),
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: ListView(
        children: [
          // ================= IMAGE SLIDER =================
          SizedBox(
            height: 320,
            child: FutureBuilder<List<ProductImage>>(
              future: _imagesFuture,
              builder: (context, snapshot) {
                final images = snapshot.hasData
                    ? [
                        p.imageUrl,
                        ...snapshot.data!.map((e) => e.imageUrl),
                      ]
                    : [p.imageUrl];

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) =>
                          setState(() => _currentImage = i),
                      itemBuilder: (_, i) {
                        return CachedNetworkImage(
                          imageUrl: images[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        );
                      },
                    ),

                    // dots
                    Positioned(
                      bottom: 10,
                      child: Row(
                        children: List.generate(
                          images.length,
                          (i) => Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImage == i ? 14 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImage == i
                                  ? Colors.greenAccent
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ================= INFO =================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${p.price.toStringAsFixed(0)} YER",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  p.description,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // ================= VARIANTS (اختياري) =================
          FutureBuilder<List<ProductVariant>>(
            future: _variantsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: snapshot.data!
                      .map(
                        (v) => ChoiceChip(
                          label: Text(v.size),
                          selected: _selectedSize == v.size,
                          onSelected: (_) {
                            setState(() {
                              _selectedSize = v.size;
                              _quantity = 1;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // ================= QUANTITY =================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text(
                "$_quantity",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const Divider(height: 40),

          // ================= COMMENTS =================
          const ProductCommentsSection(),

          const Divider(height: 40),

          // ================= SAME CATEGORY PRODUCTS =================
          FutureBuilder<List<Product>>(
            future: _sameCategoryFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final items = snapshot.data!
                  .where((e) => e.id != p.id)
                  .take(6)
                  .toList();

              if (items.isEmpty) return const SizedBox();

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final sp = items[i];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsPage(product: sp),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: sp.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (c, u) => Container(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  sp.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${sp.price.toStringAsFixed(0)} YER",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
