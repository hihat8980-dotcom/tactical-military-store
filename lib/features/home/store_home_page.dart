import 'package:flutter/material.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/category.dart';
import 'package:tactical_military_store/models/product.dart';

import 'package:tactical_military_store/features/home/product_details_page.dart';

import 'widgets/store_search_bar.dart';
import 'widgets/category_tabs.dart';
import 'widgets/products_grid.dart';
import 'widgets/store_filters_sheet.dart';

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
  int? _selectedCategoryId;

  int _notificationsCount = 0;

  // ✅ Sort Type
  ProductSortType _sortType = ProductSortType.newest;

  @override
  void initState() {
    super.initState();

    _categoriesFuture = _service.getCategories();
    _productsFuture = _service.products.getAllProducts();

    _loadNotificationsCount();
  }

  Future<void> _loadNotificationsCount() async {
    final count = await _service.getNotificationsCount();
    if (!mounted) return;

    setState(() => _notificationsCount = count);
  }

  // =====================================================
  // ✅ Filter Products (Search + Category + Sorting)
  // =====================================================
  List<Product> _filterProducts(List<Product> products) {
    var list = products;

    // Category Filter
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    // Search Filter
    if (_searchText.isNotEmpty) {
      list = list
          .where(
            (p) => p.name.toLowerCase().contains(_searchText.toLowerCase()),
          )
          .toList();
    }

    // Sorting
    if (_sortType == ProductSortType.priceLow) {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortType == ProductSortType.priceHigh) {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortType == ProductSortType.newest) {
      list.sort((a, b) => b.id.compareTo(a.id));
    }

    return list;
  }

  // =====================================================
  // ✅ UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // =====================================================
            // 🔍 Search Bar + Favorite + Notifications + Filter
            // =====================================================
            StoreSearchBar(
              notificationsCount: _notificationsCount,

              // Search
              onChanged: (value) {
                setState(() => _searchText = value);
              },

              // Notifications
              onNotificationsTap: () {
                Navigator.pushNamed(context, "/notifications");
              },

              // ✅ Favorites Tap (حل الخطأ)
              onFavoritesTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❤️ صفحة المفضلة قريبًا"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },

              // Filter Tap
              onFilterTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  builder: (_) {
                    return StoreFiltersSheet(
                      selectedSort: _sortType,
                      onApply: (newSort) {
                        setState(() => _sortType = newSort);
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 14),

            // =====================================================
            // 📂 Categories Tabs (تحت البحث مباشرة)
            // =====================================================
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                return CategoryTabs(
                  categories: snapshot.data!,
                  selectedCategoryId: _selectedCategoryId,
                  onSelected: (id) {
                    setState(() => _selectedCategoryId = id);
                  },
                );
              },
            ),

            const SizedBox(height: 18),

            // =====================================================
            // 🎁 Banner Offers
            // =====================================================
            Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    "https://i.imgur.com/qHhE9xF.jpeg",
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    color: Colors.black.withValues(alpha: 0.15),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
                child: const Text(
                  "🔥 خصم حتى 30%\nعلى المعدات التكتيكية",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================================================
            // 🛍 Products Grid
            // =====================================================
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final products = _filterProducts(snapshot.data!);

                if (products.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "🚫 لا توجد منتجات مطابقة",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                return ProductsGrid(
                  products: products,
                  onTap: (product) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
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
