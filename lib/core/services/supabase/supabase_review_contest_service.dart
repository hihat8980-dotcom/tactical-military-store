import 'package:tactical_military_store/models/product_review.dart';
import 'supabase_client.dart';
import 'supabase_auth_service.dart';

class SupabaseReviewContestService {
  final _supabase = SupabaseClientService.client;
  final _auth = SupabaseAuthService();

  // ================== GET PRODUCT REVIEWS ==================
  Future<List<ProductReview>> getProductReviews(int productId) async {
    final res = await _supabase
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (res as List).map((e) => ProductReview.fromMap(e)).toList();
  }

  // ================== ADD PRODUCT REVIEW ==================
  Future<void> addProductReview({
    required int productId,
    required String comment,
    required double rating,
  }) async {
    try {
      final user = await _auth.getCurrentUserFromDatabase();

      // ✅ nickname بدل username
      final nickname = user?.email.split("@")[0] ?? "مستخدم";

      await _supabase.from('product_reviews').insert({
        'product_id': productId,

        // ✅ العمود الصحيح
        'nickname': nickname,

        'comment': comment,
        'rating': rating.toInt(),
      });
    } catch (e) {
      throw Exception("فشل إرسال التعليق: $e");
    }
  }

  // ================== 🎯 CONTESTS ==================
  Future<List<Map<String, dynamic>>> getContests() async {
    final res = await _supabase.from('contests').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> createContest({
    required String title,
    required String description,
    DateTime? endDate,
  }) async {
    await _supabase.from('contests').insert({
      'title': title,
      'description': description,
      'end_date': endDate?.toIso8601String(),
      'is_active': true,
    });
  }

  Future<void> toggleContest({
    required int contestId,
    required bool isActive,
  }) async {
    await _supabase
        .from('contests')
        .update({'is_active': isActive})
        .eq('id', contestId);
  }
}
