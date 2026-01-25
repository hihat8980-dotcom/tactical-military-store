import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =========================
  // 📂 رفع صورة قسم
  // =========================
  Future<String> uploadCategoryImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = 'categories/$fileName';

    await _supabase.storage
        .from('categories')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return _supabase.storage
        .from('categories')
        .getPublicUrl(path);
  }

  // =========================
  // 🛒 رفع صورة منتج
  // =========================
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = 'products/$fileName';

    await _supabase.storage
        .from('products')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return _supabase.storage
        .from('products')
        .getPublicUrl(path);
  }
}
