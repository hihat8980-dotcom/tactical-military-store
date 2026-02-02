class StoreOffer {
  final int id;
  final String title;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;

  StoreOffer({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory StoreOffer.fromMap(Map<String, dynamic> map) {
    return StoreOffer(
      id: map['id'] as int,
      title: map['title'] ?? '',

      imageUrl: map['image_url'] ?? '',

      // ✅ FIX: أي قيمة ترجع من Supabase تتحول Boolean صحيح
      isActive: map['is_active'] == true ||
          map['is_active'] == 1 ||
          map['is_active'].toString() == "true",

      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
