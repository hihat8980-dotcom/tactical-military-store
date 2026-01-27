import 'package:flutter/material.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/category.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/features/home/product_details_page.dart';

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  final SupabaseService _service = SupabaseService();

  late Future<List<Category>> _categoriesFuture;
  late Future<List<Product>> _productsFuture;

  String _searchText = '';

  /// null = كل الأقسام
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _service.getCategories();
    _productsFuture = _service.products.getAllProducts();
  }

  // ================= FILTER =================
  List<Product> _filterProducts(List<Product> products) {
    var list = products;

    if (_selectedCategoryId != null) {
      list = list
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_searchText.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(_searchText.toLowerCase()),
          )
          .toList();
    }

    return list;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔍 SEARCH
            TextField(
              decoration: InputDecoration(
                hintText: "🔍 ابحث عن خوذات، ملابس، معدات...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchText = v),
            ),

            const SizedBox(height: 16),

            // 📂 CATEGORIES (تصميم خفيف واحترافي)
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final categories = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryTextTab(
                        title: 'الكل',
                        selected: _selectedCategoryId == null,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                      ...categories.map((c) {
                        final categoryId = int.parse(c.id); // ✅ int آمن

                        return _CategoryTextTab(
                          title: c.name,
                          selected: _selectedCategoryId == categoryId,
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = categoryId;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 🛍 PRODUCTS
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final products = _filterProducts(snapshot.data!);

                if (products.isEmpty) {
                  return const Center(
                    child: Text('لا توجد منتجات'),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final p = products[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsPage(product: p),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  p.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${p.price.toStringAsFixed(0)} YER",
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
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 🧩 Category Text Tab (بديل احترافي للـ Chip)
// =====================================================
class _CategoryTextTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTextTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color:
                    selected ? Colors.black : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: selected ? 22 : 0,
              decoration: BoxDecoration(
                color: selected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
