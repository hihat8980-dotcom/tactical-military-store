import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';
import 'package:tactical_military_store/models/product_variant.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/features/cart/cart_provider.dart';

import 'package:url_launcher/url_launcher.dart';

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

  String? _selectedSize;
  int _quantity = 1;

  // ✅ مؤشر الصور
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();

    _imagesFuture = SupabaseService().getProductImages(widget.product.id);
    _variantsFuture = SupabaseService().getProductVariants(widget.product.id);
  }

  // =====================================================
  // ✅ إضافة للسلة
  // =====================================================
  void _addToCart() {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ اختر المقاس أولاً")),
      );
      return;
    }

    context.read<CartProvider>().addToCart(
          product: widget.product,
          size: _selectedSize!,
          quantity: _quantity,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تمت الإضافة إلى السلة")),
    );
  }

  // =====================================================
  // ✅ شراء عبر واتساب (رقمك + ريال يمني)
  // =====================================================
  Future<void> _buyViaWhatsApp() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ اختر المقاس أولاً")),
      );
      return;
    }

    final message =
        "مرحبا، أريد شراء المنتج:\n\n"
        "${widget.product.name}\n"
        "المقاس: $_selectedSize\n"
        "الكمية: $_quantity\n"
        "السعر: ${widget.product.price} ريال يمني";

    final url =
        "https://wa.me/967770004140?text=${Uri.encodeComponent(message)}";

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  // =====================================================
  // ✅ إرسال الطلب داخل التطبيق (يتطلب تسجيل دخول)
  // =====================================================
  Future<void> _sendOrder() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ اختر المقاس أولاً")),
      );
      return;
    }

    final user = SupabaseService().currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ يجب تسجيل الدخول أولاً")),
      );
      return;
    }

    await SupabaseService().createOrder(
      productId: widget.product.id,
      productName: widget.product.name,
      productImage: widget.product.imageUrl,
      size: _selectedSize!,
      quantity: _quantity,
      price: widget.product.price,
      paymentMethod: "داخل التطبيق",
      phone: "",
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم إرسال الطلب بنجاح")),
    );
  }

  // =====================================================
  // ✅ فتح الصورة FullScreen مع Zoom
  // =====================================================
  void _openImageViewer(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        centerTitle: true,
      ),

      body: ListView(
        children: [
          // ================== صور المنتج الاحترافية ==================
          SizedBox(
            height: 330,
            child: FutureBuilder<List<ProductImage>>(
              future: _imagesFuture,
              builder: (context, snapshot) {
                final extraImages =
                    snapshot.hasData ? snapshot.data! : [];

                // ✅ جميع الصور
                final allImages = [
                  p.imageUrl,
                  ...extraImages.map((e) => e.imageUrl),
                ];

                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // ✅ سحب الصور
                    PageView.builder(
                      itemCount: allImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImage = index;
                        });
                      },
                      itemBuilder: (_, i) {
                        return GestureDetector(
                          onTap: () => _openImageViewer(allImages[i]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              allImages[i],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 80),
                            ),
                          ),
                        );
                      },
                    ),

                    // ✅ الأسهم يمين ويسار
                    Positioned(
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ),

                    Positioned(
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ),

                    // ✅ نقاط المؤشر
                    Positioned(
                      bottom: 12,
                      child: Row(
                        children: List.generate(
                          allImages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImage == index ? 14 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImage == index
                                  ? Colors.greenAccent
                                  : Colors.white54,
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

          const SizedBox(height: 20),

          // ================= معلومات المنتج =================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  p.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 15),

                Text(
                  "${p.price} ريال يمني",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // ================= المقاسات =================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "📦 اختر المقاس",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          FutureBuilder<List<ProductVariant>>(
            future: _variantsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final variants = snapshot.data!;

              return Column(
                children: variants.map((v) {
                  final selected = _selectedSize == v.size;

                  return ListTile(
                    title: Text("المقاس: ${v.size}"),
                    subtitle: Text("المتوفر: ${v.quantity}"),
                    trailing: selected
                        ? const Icon(Icons.check_circle,
                            color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedSize = v.size;
                        _quantity = 1;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // ================= التحكم بالكمية =================
          if (_selectedSize != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                Text(
                  "$_quantity",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),

          const SizedBox(height: 30),
        ],
      ),

      // ================= الأزرار =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("إضافة إلى السلة"),
              onPressed: _addToCart,
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text("طلب داخل التطبيق"),
              onPressed: _sendOrder,
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text("شراء عبر واتساب"),
              onPressed: _buyViaWhatsApp,
            ),
          ],
        ),
      ),
    );
  }
}
