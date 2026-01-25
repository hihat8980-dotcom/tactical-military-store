import 'product_image.dart';
import 'product_variant.dart';
import 'product_review.dart';

class Product {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final List<ProductReview> reviews;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    this.variants = const [],
    this.reviews = const [],
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url']?.toString() ?? '',
    );
  }

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<int>(0, (s, r) => s + r.rating);
    return total / reviews.length;
  }

  bool get isInStock =>
      variants.isEmpty || variants.any((v) => v.quantity > 0);
}
