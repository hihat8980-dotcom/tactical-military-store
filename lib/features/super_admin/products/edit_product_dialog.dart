import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';

class EditProductDialog extends StatefulWidget {
  final Product product;

  const EditProductDialog({
    super.key,
    required this.product,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  bool _loading = false;
  late Future<List<ProductImage>> _imagesFuture;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(
          text: widget.product.price.toStringAsFixed(0),
        );

    _imagesFuture =
        SupabaseService().getProductImages(widget.product.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // ================= SLUG =================
  String _generateSlug(String text) {
    final base = text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');

    return '$base-${DateTime.now().millisecondsSinceEpoch}';
  }

  // ================= SAVE =================
  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال جميع البيانات')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السعر غير صالح')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await SupabaseService().updateProduct(
        productId: widget.product.id, // ✅ FIX
        name: _nameController.text.trim(),
        slug: _generateSlug(_nameController.text.trim()), // ✅ FIX
        description: _descriptionController.text.trim(),
        price: price,
        imageUrl: widget.product.imageUrl,
        categoryId: widget.product.categoryId,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تعديل المنتج: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= DELETE IMAGE =================
  Future<void> _deleteImage(ProductImage image) async {
    await SupabaseService().deleteProductImage(image.id);

    setState(() {
      _imagesFuture =
          SupabaseService().getProductImages(widget.product.id);
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'تعديل المنتج',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'اسم المنتج'),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'الوصف'),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'السعر',
                  suffixText: 'ريال',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'صور المنتج',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              FutureBuilder<List<ProductImage>>(
                future: _imagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final images = snapshot.data ?? [];

                  if (images.isEmpty) {
                    return const Text('لا توجد صور');
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: images.map((img) {
                      return Stack(
                        children: [
                          Image.network(
                            img.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                              ),
                              color: Colors.red,
                              onPressed: () =>
                                  _deleteImage(img),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('حفظ التعديلات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
