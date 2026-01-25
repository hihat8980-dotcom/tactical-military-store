class Category {
  final String id;
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      // نحول id إلى String دائمًا
      // حتى لو كان int في قاعدة البيانات
      id: map['id'].toString(),
      name: map['name']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
    );
  }
}
