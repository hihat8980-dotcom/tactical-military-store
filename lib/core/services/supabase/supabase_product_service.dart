import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';
import 'package:tactical_military_store/models/product_variant.dart';

class SupabaseProductService {
  final _supabase = Supabase.instance.client;

  // =====================================================
  // ✅ CREATE PRODUCT
  // =====================================================
  Future<int> createProductAndReturnId({
    required String name,
    required String slug,
    required String description,
    required double price,
    required String imageUrl,
    required int categoryId,
  }) async {
    final res = await _supabase
        .from('products')
        .insert({
          'name': name,
          'slug': slug,
          'description': description,
          'price': price,
          'image_url': imageUrl,
          'category_id': categoryId,
        })
        .select('id')
        .single();

    return res['id'] as int;
  }

  // =====================================================
  // ✏️ UPDATE PRODUCT
  // =====================================================
  Future<void> updateProduct({
    required int productId,
    required String name,
    required String slug,
    required String description,
    required double price,
    required String imageUrl,
    required int categoryId,
  }) async {
    await _supabase.from('products').update({
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category_id': categoryId,
    }).eq('id', productId);
  }

  // =====================================================
  // 🗑 DELETE PRODUCT
  // =====================================================
  Future<void> deleteProduct(int productId) async {
    await _supabase
        .from('product_images')
        .delete()
        .eq('product_id', productId);

    await _supabase
        .from('product_variants')
        .delete()
        .eq('product_id', productId);

    await _supabase.from('products').delete().eq('id', productId);
  }

  // =====================================================
  // 🛍 GET ALL PRODUCTS
  // =====================================================
  Future<List<Product>> getAllProducts() async {
    final res = await _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (res as List).map((e) => Product.fromMap(e)).toList();
  }

  // =====================================================
  // 🗂 GET PRODUCTS BY CATEGORY
  // =====================================================
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final res = await _supabase
        .from('products')
        .select()
        .eq('category_id', categoryId)
        .order('created_at', ascending: false);

    return (res as List).map((e) => Product.fromMap(e)).toList();
  }

  // =====================================================
  // 🖼 PRODUCT IMAGES
  // =====================================================
  Future<void> addProductImage({
    required int productId,
    required String imageUrl,
  }) async {
    await _supabase.from('product_images').insert({
      'product_id': productId,
      'image_url': imageUrl,
    });
  }

  Future<List<ProductImage>> getProductImages(int productId) async {
    final res = await _supabase
        .from('product_images')
        .select()
        .eq('product_id', productId)
        .order('created_at');

    return (res as List).map((e) => ProductImage.fromMap(e)).toList();
  }

  Future<void> deleteProductImage(int imageId) async {
    await _supabase.from('product_images').delete().eq('id', imageId);
  }

  // =====================================================
  // 📏 PRODUCT VARIANTS
  // =====================================================
  Future<void> addProductVariant({
    required int productId,
    required String size,
    required int quantity,
  }) async {
    await _supabase.from('product_variants').insert({
      'product_id': productId,
      'size': size,
      'quantity': quantity,
    });
  }

  Future<List<ProductVariant>> getProductVariants(int productId) async {
    final res = await _supabase
        .from('product_variants')
        .select()
        .eq('product_id', productId)
        .order('created_at');

    return (res as List).map((e) => ProductVariant.fromMap(e)).toList();
  }

  Future<void> deleteProductVariant(int variantId) async {
    await _supabase.from('product_variants').delete().eq('id', variantId);
  }
}
