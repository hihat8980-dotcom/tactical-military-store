import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/category.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/app_user.dart';

import 'package:tactical_military_store/features/cart/cart_provider.dart';
import 'package:tactical_military_store/features/super_admin/products/create_product_dialog.dart';

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

  bool get _isAdmin {
    if (!_permissionsLoaded || _currentUser == null) return false;
    return _currentUser!.isSuperAdmin ||
        (_currentUser!.isAdmin && _currentUser!.canAddProducts);
  }

  void _reloadProducts() {
    setState(() {
      _productsFuture = _service.getProductsByCategory(_categoryId);
    });
  }

  // ================= حذف منتج =================
  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${product.name}" ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _service.deleteProduct(product.id);
    _reloadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
      ),

      // ➕ إضافة منتج (Admins فقط)
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.green,
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
            return const Center(child: Text("لا توجد منتجات"));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: products.length,
            itemBuilder: (_, i) {
              final product = products[i];

              return _UnifiedProductCard(
                product: product,
                isAdmin: _isAdmin,
                onDelete: () => _deleteProduct(product),
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✏️ تعديل المنتج (قريبًا)'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// 🧱 Card موحّد (User + Admin)
//////////////////////////////////////////////////////////////////

class _UnifiedProductCard extends StatelessWidget {
  final Product product;
  final bool isAdmin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _UnifiedProductCard({
    required this.product,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE =================
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // 🛠 Admin Actions
              if (isAdmin)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Row(
                    children: [
                      // ✏️ Edit
                      InkWell(
                        onTap: onEdit,
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // 🗑 Delete
                      InkWell(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
                Text(
                  "${product.price.toStringAsFixed(0)} YER",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 28,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      context.read<CartProvider>().addToCart(
                            product: product,
                            size: "Default",
                            quantity: 1,
                          );
                    },
                    child: const Text(
                      "إضافة للسلة",
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
