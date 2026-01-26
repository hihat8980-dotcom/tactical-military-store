import 'package:flutter/material.dart';
import 'package:tactical_military_store/models/product.dart';

/// عنصر داخل السلة
class CartItem {
  final Product product;
  final String size;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
}

/// Provider للسلة
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// عرض المنتجات داخل السلة
  List<CartItem> get items => _items;

  /// عدد العناصر
  int get itemsCount => _items.length;

  /// السعر الإجمالي
  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  // =====================================================
  // ✅ إضافة منتج إلى السلة
  // =====================================================
  void addToCart({
    required Product product,
    required String size,
    required int quantity,
  }) {
    // إذا المنتج موجود مسبقاً بنفس المقاس → نزيد الكمية
    final index = _items.indexWhere(
      (item) => item.product.id == product.id && item.size == size,
    );

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          size: size,
          quantity: quantity,
        ),
      );
    }

    notifyListeners();
  }

  // =====================================================
  // ✅ حذف منتج من السلة
  // =====================================================
  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  // =====================================================
  // ✅ زيادة الكمية
  // =====================================================
  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  // =====================================================
  // ✅ تقليل الكمية
  // =====================================================
  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  // =====================================================
  // ✅ تفريغ السلة
  // =====================================================
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
