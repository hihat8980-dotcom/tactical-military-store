class ProductReview {
  final int id;
  final int productId;

  final int rating;

  // ✅ اجعله غير nullable
  final String comment;

  final DateTime createdAt;
  final String nickname;

  ProductReview({
    required this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.nickname,
  });

  factory ProductReview.fromMap(Map<String, dynamic> map) {
    return ProductReview(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      rating: map['rating'] as int,

      // ✅ إذا كان null نضع نص فارغ
      comment: map['comment'] ?? "",

      createdAt: DateTime.parse(map['created_at']),
      nickname: map['nickname'] ?? "مستخدم",
    );
  }
}
