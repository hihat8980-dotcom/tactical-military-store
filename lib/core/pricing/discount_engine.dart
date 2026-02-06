import 'package:tactical_military_store/models/product.dart';

class DiscountResult {
  final double finalPrice;
  final int? percent;
  final String? source;

  DiscountResult({
    required this.finalPrice,
    this.percent,
    this.source,
  });
}

class DiscountEngine {
  static DiscountResult apply({
    required Product product,
    int? globalDiscount,
    int? productDiscount,
    int? categoryDiscount,
  }) {
    final price = product.price;

    final discounts = <int>[];

    if (globalDiscount != null) discounts.add(globalDiscount);
    if (productDiscount != null) discounts.add(productDiscount);
    if (categoryDiscount != null) discounts.add(categoryDiscount);

    if (discounts.isEmpty) {
      return DiscountResult(finalPrice: price);
    }

    final best = discounts.reduce((a, b) => a > b ? a : b);

    final newPrice = price - (price * best / 100);

    return DiscountResult(
      finalPrice: newPrice,
      percent: best,
      source: "discount",
    );
  }
}
