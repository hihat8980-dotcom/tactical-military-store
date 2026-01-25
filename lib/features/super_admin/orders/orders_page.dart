import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = SupabaseService().getAllOrders();
  }

  // ================= WHATSAPP =================
  Future<void> _sendWhatsAppMessage(String phone, String message) async {
    final url =
        'https://wa.me/967$phone?text=${Uri.encodeComponent(message)}';

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  // ================= BUILD MESSAGE =================
  String _buildWhatsAppMessage({
    required String status,
    required Map<String, dynamic> order,
  }) {
    return '''
$status

📦 المنتج: ${order['product_name']}
📏 المقاس: ${order['size']}
🔢 الكمية: ${order['quantity']}
💰 السعر: ${order['price']} دولار

شكراً لاستخدامك متجرنا ❤️
''';
  }

  // ================= CONFIRM ORDER =================
  Future<void> _confirmOrder(Map<String, dynamic> order) async {
    try {
      // ✅ تحديث الحالة فقط (بدون decreaseStock)
      await SupabaseService().updateOrderStatus(
        orderId: order['id'],
        status: 'تم التأكيد',
      );

      // ✅ رسالة واتساب جاهزة
      final message = _buildWhatsAppMessage(
        status: 'تم تأكيد طلبك ✅',
        order: order,
      );

      await _sendWhatsAppMessage(order['phone'], message);

      if (!mounted) return;

      // إعادة تحميل الطلبات
      setState(_loadOrders);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تأكيد الطلب: $e')),
      );
    }
  }

  // ================= REJECT ORDER =================
  Future<void> _rejectOrder(Map<String, dynamic> order) async {
    await SupabaseService().updateOrderStatus(
      orderId: order['id'],
      status: 'مرفوض',
    );

    final message = _buildWhatsAppMessage(
      status: 'تم رفض الطلب ❌',
      order: order,
    );

    await _sendWhatsAppMessage(order['phone'], message);

    if (!mounted) return;
    setState(_loadOrders);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد طلبات'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      o['product_image'],
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image),
                    ),
                  ),
                  title: Text(
                    o['product_name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'المقاس: ${o['size']} | الكمية: ${o['quantity']}\nالحالة: ${o['status']}',
                  ),
                  trailing: o['status'] == 'قيد المراجعة'
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _confirmOrder(o),
                              child: const Text('تأكيد'),
                            ),
                            const SizedBox(height: 6),
                            OutlinedButton(
                              onPressed: () => _rejectOrder(o),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('رفض'),
                            ),
                          ],
                        )
                      : Text(
                          o['status'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
