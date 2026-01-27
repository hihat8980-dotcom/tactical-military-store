import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tactical_military_store/models/product.dart';

class ProductActionBar extends StatelessWidget {
  final VoidCallback onAddToCart;
  final Product product;
  final String? selectedSize;
  final int quantity;

  const ProductActionBar({
    super.key,
    required this.onAddToCart,
    required this.product,
    required this.selectedSize,
    required this.quantity,
  });

  Future<void> _buyViaWhatsApp() async {
    final message =
        "أريد شراء:\n${product.name}\n"
        "المقاس: ${selectedSize ?? "بدون مقاس"}\n"
        "الكمية: $quantity\n"
        "السعر: ${product.price.toStringAsFixed(0)} YER\n"
        "${product.imageUrl}";

    final url =
        "https://wa.me/967770004140?text=${Uri.encodeComponent(message)}";

    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onAddToCart,
              child: const Text("أضف للسلة"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _buyViaWhatsApp,
              child: const Text("شراء سريع"),
            ),
          ),
        ],
      ),
    );
  }
}
