import 'package:flutter/material.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/features/home/product_details_page.dart';

class SimilarProductsGrid extends StatefulWidget {
  final int currentProductId; // ✅ int
  final Future<List<Product>> productsFuture;

  const SimilarProductsGrid({
    super.key,
    required this.currentProductId,
    required this.productsFuture,
  });

  @override
  State<SimilarProductsGrid> createState() =>
      _SimilarProductsGridState();
}

class _SimilarProductsGridState extends State<SimilarProductsGrid> {
  int _visibleCount = 4;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: widget.productsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final products = snapshot.data!
            .where((p) => p.id != widget.currentProductId) // ✅ int == int
            .toList();

        if (products.isEmpty) return const SizedBox();

        final visibleItems = products.take(_visibleCount).toList();

        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: visibleItems.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final p = visibleItems[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsPage(product: p),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${p.price.toStringAsFixed(0)} YER",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            if (_visibleCount < products.length)
              TextButton(
                onPressed: () {
                  setState(() => _visibleCount += 4);
                },
                child: const Text("عرض المزيد"),
              ),
          ],
        );
      },
    );
  }
}
