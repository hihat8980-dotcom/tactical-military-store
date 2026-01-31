import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/category.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/app_user.dart';

import 'package:tactical_military_store/features/cart/cart_provider.dart';
import 'package:tactical_military_store/features/super_admin/products/create_product_dialog.dart';
import 'package:tactical_military_store/features/home/product_details_page.dart';

class CategoryProductsPage extends StatefulWidget {
  final Category category;

  const CategoryProductsPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final SupabaseService _service = SupabaseService();

  late final int _categoryId;
  late Future<List<Product>> _productsFuture;

  AppUser? _currentUser;
  bool _permissionsLoaded = false;

  @override
  void initState() {
    super.initState();
    _categoryId = int.parse(widget.category.id);
    _productsFuture = _service.getProductsByCategory(_categoryId);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _service.getCurrentUserFromDatabase();
    if (!mounted) return;

    setState(() {
      _currentUser = user;
      _permissionsLoaded = true;
    });
  }

  bool get _canShowAddProductButton {
    if (!_permissionsLoaded || _currentUser == null) return false;
    if (_currentUser!.isSuperAdmin) return true;
    if (_currentUser!.isAdmin && _currentUser!.canAddProducts) return true;
    return false;
  }

  Future<void> _reloadProducts() async {
    setState(() {
      _productsFuture = _service.getProductsByCategory(_categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
      ),

      // ✅ زر إضافة منتج (Admins فقط)
      floatingActionButton: _canShowAddProductButton
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text("إضافة منتج"),
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) =>
                      CreateProductDialog(categoryId: _categoryId),
                );
                if (result == true) _reloadProducts();
              },
            )
          : null,

      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد منتجات في هذا القسم"));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(14),

            // ✅ Smaller Cards
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),

            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: product),
                    ),
                  );
                },
                child: _CompactProductCard(product: product),
              );
            },
          );
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// ✅ Compact Product Card + Small Cart Button
//////////////////////////////////////////////////////////////////

class _CompactProductCard extends StatelessWidget {
  final Product product;

  const _CompactProductCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141A22),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE + CART BUTTON =================
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  product.imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // ✅ Small Cart Button (Top Right)
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    context.read<CartProvider>().addToCart(
                          product: product,
                          size: "Default",
                          quantity: 1,
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "🛒 تمت إضافة ${product.name} إلى السلة",
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ================= INFO =================
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                // Price
                Text(
                  "${product.price.toStringAsFixed(0)} YER",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),

                const SizedBox(height: 6),

                // Add Button
                SizedBox(
                  height: 28,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      context.read<CartProvider>().addToCart(
                            product: product,
                            size: "Default",
                            quantity: 1,
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("🛒 تمت إضافة ${product.name} إلى السلة"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text(
                      "إضافة",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
