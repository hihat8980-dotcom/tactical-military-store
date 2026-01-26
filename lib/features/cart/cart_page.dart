import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tactical_military_store/core/theme/military_theme.dart';
import 'package:tactical_military_store/features/cart/cart_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // ===============================
  // ✅ Checkout via WhatsApp
  // ===============================
  Future<void> _checkoutWhatsApp(BuildContext context) async {
    final cart = context.read<CartProvider>();

    if (cart.items.isEmpty) return;

    String message = "🛒 طلب جديد من المتجر العسكري:\n\n";

    for (var item in cart.items) {
      message +=
          "📌 ${item.product.name}\n"
          "المقاس: ${item.size}\n"
          "الكمية: ${item.quantity}\n"
          "السعر: ${item.totalPrice.toStringAsFixed(0)} ريال\n\n";
    }

    message += "✅ الإجمالي: ${cart.totalAmount.toStringAsFixed(0)} ريال يمني";

    final url =
        "https://wa.me/967770004140?text=${Uri.encodeComponent(message)}";

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: MilitaryTheme.sand,

      appBar: AppBar(
        title: const Text("🛒 السلة"),
        centerTitle: true,
      ),

      // ===============================
      // ✅ Empty Cart
      // ===============================
      body: cart.items.isEmpty
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(22),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MilitaryTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MilitaryTheme.border.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  "السلة فارغة حاليا 🛍️",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )

          // ===============================
          // ✅ Cart Items List
          // ===============================
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: MilitaryTheme.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                MilitaryTheme.border.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // ✅ Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 75,
                                height: 75,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image, size: 50),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // ✅ Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "المقاس: ${item.size}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "${item.totalPrice.toStringAsFixed(0)} ريال",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ✅ Quantity Controls
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.greenAccent),
                                  onPressed: () {
                                    cart.increaseQuantity(item);
                                  },
                                ),
                                Text(
                                  "${item.quantity}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.orangeAccent),
                                  onPressed: () {
                                    cart.decreaseQuantity(item);
                                  },
                                ),
                              ],
                            ),

                            // ✅ Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () {
                                cart.removeItem(item);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ===============================
                // ✅ Total + Checkout
                // ===============================
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: MilitaryTheme.card,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "الإجمالي:",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            "${cart.totalAmount.toStringAsFixed(0)} ريال",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: const Text(
                            "إتمام الطلب عبر واتساب",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _checkoutWhatsApp(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
