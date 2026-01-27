import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tactical_military_store/core/theme/military_theme.dart';
import 'package:tactical_military_store/core/utils/currency_helper.dart';
import 'package:tactical_military_store/features/cart/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: MilitaryTheme.sand,
      appBar: AppBar(title: const Text("Cart")),
      body: cart.items.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return ListTile(
                        leading: Image.network(
                          item.product.imageUrl,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.product.name),
                        subtitle: Text("Size: ${item.size}"),
                        trailing: Text(
                          CurrencyHelper.format(
                              context, item.totalPrice),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total"),
                      Text(
                        CurrencyHelper.format(
                            context, cart.totalAmount),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
