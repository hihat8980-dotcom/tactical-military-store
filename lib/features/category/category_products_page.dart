import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/category.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/app_user.dart';
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
      ),

      floatingActionButton: _canShowAddProductButton
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
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
            return const Center(child: Text('لا توجد منتجات في هذا القسم'));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.72,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsPage(product: product),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= IMAGE =================
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),

                          // 💰 PRICE BADGE
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${product.price} \$',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // ✏️ EDIT BUTTON
                          if (_canShowAddProductButton)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.6),
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // ================= INFO =================
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'جودة عالية • منتج مضمون',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
    );
  }
}
