import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // =====================================================
  // ✅ Load Orders By auth_id (Professional)
  // =====================================================
  void _loadOrders() {
    final user = SupabaseService().currentUser;

    if (user == null) {
      _ordersFuture = Future.value([]);
      return;
    }

    _ordersFuture =
        SupabaseService().getUserOrdersByAuthId(authId: user.id);
  }

  // =====================================================
  // ❌ Cancel Order
  // =====================================================
  Future<void> _rejectOrder(int orderId) async {
    await SupabaseService().updateOrderStatus(
      orderId: orderId,
      status: "مرفوض",
    );

    setState(() {
      _loadOrders();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ تم إلغاء الطلب بنجاح"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // =====================================================
  // 🖥 UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "📦 طلباتي",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
          ),
        ),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }

          // No Data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "🚫 لا توجد طلبات حتى الآن",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final o = orders[i];

              return Card(
                color: const Color(0xFF141A22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 14),
                child: ListTile(
                  title: Text(
                    o['product_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "📌 الحالة: ${o['status']}\n📏 المقاس: ${o['size']}\n🔢 الكمية: ${o['quantity']}",
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ),

                  trailing: o['status'] == "قيد المراجعة"
                      ? TextButton(
                          onPressed: () => _rejectOrder(o['id']),
                          child: const Text(
                            "إلغاء",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
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
