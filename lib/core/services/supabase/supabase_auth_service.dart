import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tactical_military_store/models/app_user.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =====================================================
  // 🔐 SIGN IN
  // =====================================================

  Future<({String token, String role})> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final session = response.session;
    final user = response.user;

    if (session == null || user == null) {
      throw Exception("فشل تسجيل الدخول");
    }

    // ✅ جلب role من جدول users
    final row = await _supabase
        .from("users")
        .select("role")
        .eq("auth_id", user.id)
        .maybeSingle();

    final String role = (row?['role'] as String?) ?? "user";

    await updateLastSeen();

    return (
      token: session.accessToken,
      role: role,
    );
  }

  // =====================================================
  // 🆕 SIGN UP (Professional + Secure)
  // =====================================================

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    String role = "user",
  }) async {
    // =====================================================
    // ✅ إنشاء الحساب داخل Auth فقط
    // =====================================================
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,

      // ✅ تخزين nickname داخل metadata
      data: {
        "nickname": nickname,
        "role": role,
      },
    );

    final user = res.user;

    if (user == null) {
      throw Exception("فشل إنشاء الحساب");
    }

    // ✅ لا نقوم بأي insert هنا
    // لأن Trigger داخل Supabase سيقوم بإنشاء الصف تلقائيًا
  }

  // =====================================================
  // 👤 CURRENT USER FROM DATABASE
  // =====================================================

  Future<AppUser?> getCurrentUserFromDatabase() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    final data = await _supabase
        .from("users")
        .select()
        .eq("auth_id", authUser.id)
        .maybeSingle();

    if (data == null) return null;

    return AppUser.fromMap(data);
  }

  // =====================================================
  // 👥 USERS MANAGEMENT (Admin)
  // =====================================================

  Future<List<AppUser>> getAllUsers() async {
    final res = await _supabase.from("users").select();
    return (res as List).map((e) => AppUser.fromMap(e)).toList();
  }

  Future<void> updateUserRole({
    required int userId,
    required String role,
  }) async {
    await _supabase.from("users").update({
      "role": role,
    }).eq("id", userId);
  }

  Future<void> setAdminAddProductPermission({
    required int userId,
    required bool value,
  }) async {
    await _supabase.from("users").update({
      "can_add_products": value,
    }).eq("id", userId);
  }

  // =====================================================
  // 🟢 UPDATE LAST SEEN
  // =====================================================

  Future<void> updateLastSeen() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from("users").update({
      "last_seen_at": DateTime.now().toIso8601String(),
      "is_online": true,
    }).eq("auth_id", user.id);
  }

  // =====================================================
  // 🚪 SESSION
  // =====================================================

  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
