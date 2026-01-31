class AppUser {
  final int id;
  final String email;
  final String role;
  final String authId;

  final bool canAddProducts;
  final DateTime? lastSeenAt;
  final bool isOnline;

  // ✅ nickname موجود في جدول users
  final String nickname;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.authId,
    required this.nickname,
    required this.canAddProducts,
    required this.lastSeenAt,
    required this.isOnline,
  });

  // =====================================================
  // ✅ GETTERS احترافية (هذه تحل كل أخطاء isAdmin وغيرها)
  // =====================================================

  /// 👑 هل هو Super Admin؟
  bool get isSuperAdmin => role == "super_admin";

  /// 🛠 هل هو Admin؟
  bool get isAdmin => role == "admin";

  /// 👤 هل هو User عادي؟
  bool get isUser => role == "user";

  /// 🟢 نص آخر ظهور للمستخدم
  String get lastSeenText {
    if (isOnline) return "🟢 متصل الآن";

    if (lastSeenAt == null) return "غير معروف";

    final diff = DateTime.now().difference(lastSeenAt!);

    if (diff.inMinutes < 1) return "قبل لحظات";
    if (diff.inMinutes < 60) return "قبل ${diff.inMinutes} دقيقة";
    if (diff.inHours < 24) return "قبل ${diff.inHours} ساعة";
    return "قبل ${diff.inDays} يوم";
  }

  // =====================================================
  // ✅ Factory
  // =====================================================

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? 0,
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      authId: map['auth_id'] ?? '',

      nickname: map['nickname'] ?? "مستخدم",

      canAddProducts: map['can_add_products'] ?? false,

      lastSeenAt: map['last_seen_at'] != null
          ? DateTime.tryParse(map['last_seen_at'])
          : null,

      isOnline: map['is_online'] ?? false,
    );
  }
}