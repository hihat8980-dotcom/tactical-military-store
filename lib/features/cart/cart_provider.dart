import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  // ===============================
  // Getter
  // ===============================
  List<Map<String, dynamic>> get items => _items;

  // ===============================
  // Total Items Count
  // ===============================
  int get totalItems {
    int count = 0;
    for (var item in _items) {
      count += item['quantity'] as int;
    }
    return count;
  }

  // ===============================
  // Total Price
  // ===============================
  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += (item['price'] * item['quantity']);
    }
    return total;
  }

  // ===============================
  // Add Product
  // ===============================
  void addToCart(Map<String, dynamic> product) {
    final index = _items.indexWhere((p) => p['id'] == product['id']);

    if (index != -1) {
      _items[index]['quantity'] += 1;
    } else {
      _items.add({
        "id": product['id'],
        "name": product['name'],
        "price": product['price'],
        "image": product['image'],
        "quantity": 1,
      });
    }

    notifyListeners();
  }

  // ===============================
  // Remove Product
  // ===============================
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item['id'] == productId);
    notifyListeners();
  }

  // ===============================
  // Clear Cart
  // ===============================
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
