import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/theme/military_theme.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ خلفية سكري رسمية
      backgroundColor: MilitaryTheme.sand,

      appBar: AppBar(
        title: const Text("🛒 السلة"),
        centerTitle: true,
      ),

      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MilitaryTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: MilitaryTheme.border.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 6),
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
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
      ),
    );
  }
}
