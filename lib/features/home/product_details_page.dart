import 'package:flutter/material.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';
import 'package:tactical_military_store/models/product_variant.dart';
import 'package:tactical_military_store/models/product_review.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';
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
  late Future<List<ProductReview>> _reviewsFuture;

  final TextEditingController _commentController = TextEditingController();

  double _rating = 5;

  // ✅ المقاس المختار
  String? _selectedSize;

  // ✅ الكمية المختارة
  int _quantity = 1;

  @override
  void initState() {
    super.initState();

    _imagesFuture = SupabaseService().getProductImages(widget.product.id);
    _variantsFuture = SupabaseService().getProductVariants(widget.product.id);
    _reviewsFuture = SupabaseService().getProductReviews(widget.product.id);
  }

  // ================= WHATSAPP =================
  Future<void> _buyViaWhatsApp() async {
    // ✅ منع الشراء بدون اختيار مقاس
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ الرجاء اختيار المقاس أولاً"),
        ),
      );
      return;
    }

    final message =
        'مرحبا، أريد شراء المنتج: ${widget.product.name}'
        '\nالمقاس: $_selectedSize'
        '\nالكمية: $_quantity'
        '\nالسعر: ${widget.product.price} \$';

    final url =
        'https://wa.me/967774299770?text=${Uri.encodeComponent(message)}';

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  // ================= WALLET =================
  void _showWalletPayment() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'الدفع عبر المحافظ الإلكترونية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'حوّل المبلغ إلى الرقم التالي ثم أرسل صورة التحويل عبر واتساب',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      '774299770',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _WalletLogo(label: 'جيب'),
                  _WalletLogo(label: 'جوالي'),
                  _WalletLogo(label: 'كريمي'),
                  _WalletLogo(label: 'فلوسك'),
                ],
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('إرسال التحويل عبر واتساب'),
                onPressed: _buyViaWhatsApp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= ADD REVIEW =================
  Future<void> _addReview() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await SupabaseService().addProductReview(
        productId: widget.product.id,
        comment: _commentController.text.trim(),
        rating: _rating,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم إرسال التعليق بنجاح"),
        ),
      );

      _commentController.clear();

      setState(() {
        _reviewsFuture = SupabaseService().getProductReviews(widget.product.id);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ فشل إرسال التعليق: $e"),
        ),
      );
    }
  }

  // ================= SEND ORDER (AUTH ID FIXED) =================
  Future<void> _sendOrder() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ اختر المقاس أولاً"),
        ),
      );
      return;
    }

    try {
      // ✅ المستخدم الحالي
      final user = SupabaseService().currentUser;

      if (user == null) {
        throw Exception("❌ يجب تسجيل الدخول أولاً");
      }

      await SupabaseService().createOrder(
        productId: widget.product.id,
        productName: widget.product.name,
        productImage: widget.product.imageUrl,
        size: _selectedSize!,
        quantity: _quantity,
        price: widget.product.price,
        paymentMethod: "داخل التطبيق",

        // ✅ الهاتف لم يعد ثابت (نضعه مؤقتًا فارغ أو optional)
        phone: "",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم إرسال الطلب بنجاح وربطه بحسابك"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ فشل إرسال الطلب: $e"),
        ),
      );
    }
  }

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
          // ================= IMAGES =================
          SizedBox(
            height: 280,
            child: FutureBuilder<List<ProductImage>>(
              future: _imagesFuture,
              builder: (context, snapshot) {
                final images = <String>[
                  p.imageUrl,
                  if (snapshot.hasData)
                    ...snapshot.data!.map((e) => e.imageUrl),
                ];

                return PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (_, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 80),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // ================= BASIC INFO =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  p.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  p.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  '${p.price} \$',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ================= VARIANTS =================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "📦 اختر المقاس المتوفر",
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

              if (variants.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("لا توجد مقاسات حاليا")),
                );
              }

              return Column(
                children: variants.map((v) {
                  final isSelected = _selectedSize == v.size;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text("المقاس: ${v.size}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("الكمية المتوفرة: ${v.quantity}"),
                          const SizedBox(height: 6),

                          if (isSelected)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: _quantity > 1
                                      ? () {
                                          setState(() {
                                            _quantity--;
                                          });
                                        }
                                      : null,
                                ),
                                Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: _quantity < v.quantity
                                      ? () {
                                          setState(() {
                                            _quantity++;
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                        ],
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: Colors.green)
                          : const Icon(Icons.circle_outlined),
                      onTap: () {
                        setState(() {
                          _selectedSize = v.size;
                          _quantity = 1;
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 30),

          // ================= REVIEWS =================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "⭐ تقييمات المستخدمين",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          FutureBuilder<List<ProductReview>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final reviews = snapshot.data!;

              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("لا توجد تعليقات بعد")),
                );
              }

              return Column(
                children: reviews.map((r) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: ListTile(
                      title: Text(r.nickname),
                      subtitle: Text(r.comment ?? "بدون تعليق"),
                      trailing: Text("⭐ ${r.rating}"),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 30),

          // ================= ADD REVIEW FORM =================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "✍️ أضف تعليقك",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: "اكتب تعليقك هنا...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                DropdownButton<double>(
                  value: _rating,
                  items: [1, 2, 3, 4, 5]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.toDouble(),
                          child: Text("⭐ $e"),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _rating = v!),
                ),

                ElevatedButton(
                  onPressed: _addReview,
                  child: const Text("إرسال التعليق"),
                ),
              ],
            ),
          ),
        ],
      ),

      // ================= ACTIONS =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text("طلب المنتج الآن"),
              onPressed: _sendOrder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text("الشراء عبر واتساب"),
              onPressed: _buyViaWhatsApp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text("الدفع عبر المحافظ الإلكترونية"),
              onPressed: _showWalletPayment,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= WALLET LOGO =================
class _WalletLogo extends StatelessWidget {
  final String label;

  const _WalletLogo({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade200,
          child: Text(
            label.characters.first,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
