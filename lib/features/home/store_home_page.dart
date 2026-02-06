import 'package:flutter/material.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';

import 'package:tactical_military_store/models/category.dart';
import 'package:tactical_military_store/models/product.dart';

import 'package:tactical_military_store/features/home/product_details_page.dart';

import 'widgets/store_search_bar.dart';
import 'widgets/category_tabs.dart';
import 'widgets/products_grid.dart';
import 'widgets/store_filters_sheet.dart';

/// ✅ عروض البانر (Amazon Slider)
import 'widgets/store_offers_banner.dart';

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

  /// ✅ Sort Type
  ProductSortType _sortType = ProductSortType.newest;

  @override
  void initState() {
    super.initState();

    /// تحميل الأقسام
    _categoriesFuture = _service.getCategories();

    /// تحميل المنتجات
    _productsFuture = _service.products.getAllProducts();

    /// تحميل الإشعارات
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

    /// فلتر القسم
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    /// فلتر البحث
    if (_searchText.isNotEmpty) {
      list = list
          .where(
            (p) => p.name.toLowerCase().contains(_searchText.toLowerCase()),
          )
          .toList();
    }

    /// Sorting
    if (_sortType == ProductSortType.priceLow) {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortType == ProductSortType.priceHigh) {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else {
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
            // 🔍 Search Bar + Notifications + Filter
            // =====================================================
            StoreSearchBar(
              notificationsCount: _notificationsCount,

              /// Search
              onChanged: (value) {
                setState(() => _searchText = value);
              },

              /// Notifications
              onNotificationsTap: () {
                Navigator.pushNamed(context, "/notifications");
              },

              /// Favorites
              onFavoritesTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❤️ صفحة المفضلة قريبًا"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },

              /// Filter
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
            // 📂 Categories Tabs
            // =====================================================
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox();
                }

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
            // 🎁 Banner Offers Slider (Dynamic Amazon Style)
            // =====================================================
            const StoreOffersBanner(),

            const SizedBox(height: 22),

            // =====================================================
            // 🛍 Products Grid
            // =====================================================
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                /// Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                /// Error
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text("❌ خطأ أثناء تحميل المنتجات"),
                  );
                }

                final products = _filterProducts(snapshot.data!);

                /// No Products
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
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

                /// Products Grid
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
