import 'package:tactical_military_store/models/product_review.dart';

import 'supabase_client.dart';
import 'supabase_auth_service.dart';

class SupabaseReviewContestService {
  final _supabase = SupabaseClientService.client;
  final _auth = SupabaseAuthService();

  // =====================================================
  // ⭐ GET PRODUCT REVIEWS
  // =====================================================
  Future<List<ProductReview>> getProductReviews(int productId) async {
    final res = await _supabase
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => ProductReview.fromMap(e))
        .toList();
  }

  // =====================================================
  // ✍️ ADD PRODUCT REVIEW (مستخدم أو زائر)
  // =====================================================
  Future<void> addProductReview({
    required int productId,
    required String comment,
    required double rating,
  }) async {
    try {
      // ✅ نحاول نجيب المستخدم الحالي من قاعدة البيانات
      final user = await _auth.getCurrentUserFromDatabase();

      // ✅ nickname احترافي بدون أي أخطاء
      final nickname = user?.email.split("@")[0] ?? "مستخدم";

      await _supabase.from('product_reviews').insert({
        'product_id': productId,
        'nickname': nickname,
        'comment': comment,
        'rating': rating.toInt(),
      });
    } catch (e) {
      throw Exception("❌ فشل إرسال التقييم: $e");
    }
  }

  // =====================================================
  // 🗑 DELETE REVIEW (SUPER ADMIN ONLY)
  // =====================================================
  Future<void> deleteReview(int reviewId) async {
    try {
      await _supabase.from("product_reviews").delete().eq("id", reviewId);
    } catch (e) {
      throw Exception("❌ فشل حذف التعليق: $e");
    }
  }

  // =====================================================
  // 🎯 CONTESTS SYSTEM
  // =====================================================

  Future<List<Map<String, dynamic>>> getContests() async {
    final res = await _supabase
        .from('contests')
        .select()
        .order("created_at", ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> createContest({
    required String title,
    required String description,
    DateTime? endDate,
  }) async {
    try {
      await _supabase.from('contests').insert({
        'title': title,
        'description': description,
        'end_date': endDate?.toIso8601String(),
        'is_active': true,
      });
    } catch (e) {
      throw Exception("❌ فشل إنشاء المسابقة: $e");
    }
  }

  Future<void> toggleContest({
    required int contestId,
    required bool isActive,
  }) async {
    try {
      await _supabase
          .from('contests')
          .update({'is_active': isActive})
          .eq('id', contestId);
    } catch (e) {
      throw Exception("❌ فشل تحديث حالة المسابقة: $e");
    }
  }
}
