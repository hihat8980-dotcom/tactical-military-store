class AppUser {
  final int id;
  final String email;
  final String role;

  // ✅ صلاحية إضافة المنتجات (للـ Admin)
  final bool canAddProducts;

  // آخر ظهور
  final DateTime? lastSeen;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.canAddProducts,
    required this.lastSeen,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int,
      email: map['email'] as String,
      role: map['role'] as String,

      // 👇 هنا الحل الأساسي
      canAddProducts: map['can_add_products'] as bool? ?? false,

      lastSeen: map['last_seen_at'] != null
          ? DateTime.parse(map['last_seen_at'])
          : null,
    );
  }

  // ================= Helpers =================

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin';

  String get lastSeenText {
    if (lastSeen == null) return 'غير متصل';

    final diff = DateTime.now().difference(lastSeen!);

    if (diff.inMinutes < 1) return 'متصل الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'قبل ${diff.inDays} يوم';
  }
}
