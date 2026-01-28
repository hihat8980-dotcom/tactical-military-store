import 'package:flutter/material.dart';

class ProductCommentsSection extends StatelessWidget {
  const ProductCommentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "💬 آراء العملاء",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _comment(
            name: "محمد",
            comment: "جودة ممتازة وسعر مناسب 👌",
            rating: 5,
          ),
          _comment(
            name: "أحمد",
            comment: "التوصيل سريع والمنتج مطابق",
            rating: 4,
          ),
          _comment(
            name: "سالم",
            comment: "أنصح به 👍",
            rating: 5,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _comment({
    required String name,
    required String comment,
    required int rating,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 16,
                    color: i < rating
                        ? Colors.amber
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
