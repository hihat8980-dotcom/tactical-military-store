import 'package:flutter/material.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/category.dart';

import 'package:tactical_military_store/features/super_admin/products/create_product_dialog.dart';

class SuperAdminProductsPage extends StatefulWidget {
  const SuperAdminProductsPage({super.key});

  @override
  State<SuperAdminProductsPage> createState() =>
      _SuperAdminProductsPageState();
}

class _SuperAdminProductsPageState
    extends State<SuperAdminProductsPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // ================= تحميل المنتجات =================
  void _loadProducts() {
    _productsFuture = SupabaseService().getAllProducts();
  }

  // ================= حذف منتج =================
  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${product.name}" ؟'),
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

    await SupabaseService().deleteProduct(product.id);

    if (!mounted) return;
    _loadProducts();
    setState(() {});
  }

  // ================= إضافة منتج =================
  Future<void> _addProduct() async {
    final categoryId = await _selectCategoryDialog();
    if (categoryId == null) return;

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateProductDialog(
        categoryId: categoryId,
      ),
    );

    if (result == true && mounted) {
      _loadProducts();
      setState(() {});
    }
  }

  // ================= Dialog اختيار القسم =================
  Future<int?> _selectCategoryDialog() async {
    final categories = await SupabaseService().getCategories();

    if (!mounted) return null;

    return showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('اختر القسم'),
        children: categories.map((Category c) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, int.parse(c.id));
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(c.imageUrl),
                ),
                const SizedBox(width: 12),
                Text(c.name),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 إدارة المنتجات'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
        onPressed: _addProduct,
      ),

      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '❌ خطأ: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('لا توجد منتجات'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (_, i) {
              final p = products[i];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p.imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${p.price.toStringAsFixed(0)} YER',
                    style: const TextStyle(color: Colors.green),
                  ),
                  trailing: IconButton(
                    tooltip: 'حذف',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(p),
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
