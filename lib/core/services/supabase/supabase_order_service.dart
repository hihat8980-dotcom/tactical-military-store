import 'package:tactical_military_store/core/services/supabase/supabase_client.dart';

class SupabaseOrderService {
  final _supabase = SupabaseClientService.client;

  // =====================================================
  // 🧾 CREATE ORDER (auth_id الأفضل)
  // =====================================================
  Future<void> createOrder({
    required int productId,
    required String productName,
    required String productImage,
    required String size,
    required int quantity,
    required double price,
    required String paymentMethod,
    required String phone,
  }) async {
    final user = _supabase.auth.currentUser;

    await _supabase.from('orders').insert({
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'size': size,
      'quantity': quantity,
      'price': price,
      'payment_method': paymentMethod,
      'phone': phone,

      // ✅ الأفضل: ربط الطلب بالمستخدم الحقيقي
      'user_auth_id': user?.id,

      'status': 'قيد المراجعة',
    });
  }

  // =====================================================
  // 📌 GET ALL ORDERS (للأدمن)
  // =====================================================
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final res = await _supabase.from('orders').select().order('created_at');
    return List<Map<String, dynamic>>.from(res);
  }

  // =====================================================
  // ✅ GET USER ORDERS BY AUTH ID
  // =====================================================
  Future<List<Map<String, dynamic>>> getUserOrdersByAuthId({
    required String authId,
  }) async {
    final res = await _supabase
        .from('orders')
        .select()
        .eq('user_auth_id', authId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(res);
  }

  // =====================================================
  // ✅ UPDATE ORDER STATUS
  // =====================================================
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    await _supabase.from('orders').update({
      'status': status,
    }).eq('id', orderId);
  }
}
