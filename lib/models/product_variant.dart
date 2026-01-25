class ProductVariant {
  final String size;
  final int quantity;

  ProductVariant({
    required this.size,
    required this.quantity,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      size: map['size'] as String,
      quantity: map['quantity'] as int,
    );
  }
}
