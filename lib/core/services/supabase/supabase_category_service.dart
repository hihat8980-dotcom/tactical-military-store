import 'package:tactical_military_store/models/category.dart';
import 'supabase_client.dart';

class SupabaseCategoryService {
  final _supabase = SupabaseClientService.client;

  // ================= جلب الأقسام =================
  Future<List<Category>> getCategories() async {
    final res = await _supabase
        .from('categories')
        .select()
        .order('created_at');

    return (res as List)
        .map((e) => Category.fromMap(e))
        .toList();
  }

  // ================= إنشاء قسم =================
  Future<void> createCategory({
    required String name,
    required String imageUrl,
  }) async {
    await _supabase.from('categories').insert({
      'name': name,
      'image_url': imageUrl,
    });
  }

  // ================= تعديل قسم (FIXED) =================
  /// ❗ id أصبح String
  Future<void> updateCategory({
    required String id,
    required String name,
    required String imageUrl,
  }) async {
    await _supabase
        .from('categories')
        .update({
          'name': name,
          'image_url': imageUrl,
        })
        .eq('id', id);
  }

  // ================= حذف قسم (FIXED) =================
  /// ❗ id أصبح String
  Future<void> deleteCategory(String id) async {
    await _supabase
        .from('categories')
        .delete()
        .eq('id', id);
  }
}
