import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';
import 'package:tactical_military_store/models/product_variant.dart';
import 'supabase_client.dart';

class SupabaseProductService {
  final _supabase = SupabaseClientService.client;

  // =====================================================
  // ✅ إنشاء منتج وإرجاع ID
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
  // ✅ جلب المنتجات حسب القسم
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
  // 🛍️ جلب جميع المنتجات (Store Home Page)
  // =====================================================
  Future<List<Product>> getAllProducts() async {
    final res = await _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (res as List).map((e) => Product.fromMap(e)).toList();
  }

  // =====================================================
  // ✅ إضافة صورة إضافية للمنتج
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

  // =====================================================
  // ✅ جلب صور المنتج
  // =====================================================
  Future<List<ProductImage>> getProductImages(int productId) async {
    final res = await _supabase
        .from('product_images')
        .select()
        .eq('product_id', productId)
        .order('created_at');

    return (res as List).map((e) => ProductImage.fromMap(e)).toList();
  }

  // =====================================================
  // ✅ إضافة مقاس + كمية للمنتج
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

  // =====================================================
  // ✅ جلب المقاسات والكميات للمنتج
  // =====================================================
  Future<List<ProductVariant>> getProductVariants(int productId) async {
    final res = await _supabase
        .from('product_variants')
        .select()
        .eq('product_id', productId)
        .order('created_at');

    return (res as List).map((e) => ProductVariant.fromMap(e)).toList();
  }
}
