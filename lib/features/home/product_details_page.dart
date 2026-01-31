import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';
import 'package:tactical_military_store/models/product_variant.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/features/cart/cart_provider.dart';

import 'widgets/product_image_slider.dart';
import 'widgets/product_info_section.dart';
import 'widgets/product_variants_section.dart';
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

  bool _isSuperAdmin = false;

  @override
  void initState() {
    super.initState();

    final service = SupabaseService();

    _imagesFuture = service.getProductImages(widget.product.id);
    _variantsFuture = service.getProductVariants(widget.product.id);
    _sameCategoryFuture =
        service.getProductsByCategory(widget.product.categoryId);

    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await SupabaseService().getCurrentUserFromDatabase();
    if (user != null && user.role == "super_admin") {
      setState(() => _isSuperAdmin = true);
    }
  }

  // ================= ADD TO CART =================
  void _addToCart() {
    context.read<CartProvider>().addToCart(
          product: widget.product,
          size: _selectedSize ?? "بدون مقاس",
          quantity: _quantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تمت الإضافة إلى السلة")),
    );
  }

  // ================= WHATSAPP =================
  Future<void> _buyViaWhatsApp() async {
    final message =
        "🛒 طلب شراء جديد\n\n"
        "📌 المنتج: ${widget.product.name}\n"
        "📏 المقاس: ${_selectedSize ?? "بدون مقاس"}\n"
        "🔢 الكمية: $_quantity\n"
        "💰 السعر: ${widget.product.price.toStringAsFixed(0)} YER\n\n"
        "🖼 صورة المنتج:\n${widget.product.imageUrl}";

    final url =
        "https://wa.me/967770004140?text=${Uri.encodeComponent(message)}";

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          p.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // ✅ Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text("أضف للسلة"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _buyViaWhatsApp,
                icon: const Icon(Icons.flash_on),
                label: const Text("شراء سريع"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          // ✅ Image Slider
          Padding(
            padding: const EdgeInsets.all(14),
            child: ProductImageSlider(
              product: p,
              imagesFuture: _imagesFuture,
            ),
          ),

          // ✅ Info Section
          ProductInfoSection(product: p),

          const SizedBox(height: 10),

          // ✅ Variants Section (اختياري)
          ProductVariantsSection(
            variantsFuture: _variantsFuture,
            selectedSize: _selectedSize,
            onSelected: (v) {
              setState(() {
                _selectedSize = v;
                _quantity = 1;
              });
            },
          ),

          const SizedBox(height: 18),

          // ✅ Quantity Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _qtyButton(
                icon: Icons.remove,
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  "$_quantity",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _qtyButton(
                icon: Icons.add,
                onTap: () => setState(() => _quantity++),
              ),
            ],
          ),

          const Divider(height: 40),

          // ✅ Comments Section (مصحح)
          ProductCommentsSection(
            productId: p.id,
            isSuperAdmin: _isSuperAdmin,
          ),

          const Divider(height: 40),

          // ✅ Same Category Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "🛍 منتجات من نفس القسم",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          FutureBuilder<List<Product>>(
            future: _sameCategoryFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final items = snapshot.data!
                  .where((e) => e.id != p.id)
                  .take(6)
                  .toList();

              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("لا توجد منتجات أخرى")),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final sp = items[i];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(product: sp),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withValues(alpha: 0.08),
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: Image.network(
                                sp.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
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
                                const SizedBox(height: 5),
                                Text(
                                  "${sp.price.toStringAsFixed(0)} YER",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= Quantity Button =================
  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.grey.shade200,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon,size: 20),
        ),
      ),
    );
  }
}
