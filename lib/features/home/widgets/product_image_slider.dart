import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';

class ProductImageSlider extends StatefulWidget {
  final Product product;
  final Future<List<ProductImage>> imagesFuture;

  const ProductImageSlider({
    super.key,
    required this.product,
    required this.imagesFuture,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _index = 0;
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: FutureBuilder<List<ProductImage>>(
        future: widget.imagesFuture,
        builder: (context, snapshot) {
          final images = [
            widget.product.imageUrl,
            ...?snapshot.data?.map((e) => e.imageUrl),
          ];

          return Stack(
            alignment: Alignment.center,
            children: [
              // ================= SLIDER =================
              PageView.builder(
                controller: _controller,
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  return CachedNetworkImage(
                    imageUrl: images[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 40),
                  );
                },
              ),

              // ================= LEFT ARROW =================
              Positioned(
                left: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    if (_index > 0) {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),

              // ================= RIGHT ARROW =================
              Positioned(
                right: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    if (_index < images.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),

              // ================= DOTS =================
              Positioned(
                bottom: 10,
                child: Row(
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _index == i ? 14 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _index == i
                            ? Colors.greenAccent
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
