class ProductImage {
  final int id;
  final int productId;
  final String imageUrl;

  ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
  });

  factory ProductImage.fromMap(Map<String, dynamic> map) {
    return ProductImage(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      imageUrl: map['image_url'] as String,
    );
  }
}
