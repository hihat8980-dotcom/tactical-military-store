import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tactical_military_store/core/services/storage_service.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

class CreateProductDialog extends StatefulWidget {
  /// ✅ القسم الذي سيُضاف فيه المنتج
  final int categoryId;

  const CreateProductDialog({
    super.key,
    required this.categoryId,
  });

  @override
  State<CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<CreateProductDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  /// 🖼 صور المنتج (الأولى = رئيسية)
  final List<Uint8List> _images = [];

  /// 📏 المقاسات (اختياري)
  final List<_VariantRow> _variants = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    for (final v in _variants) {
      v.dispose();
    }
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

  // ================= PICK IMAGES =================
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;

    for (final file in files) {
      _images.add(await file.readAsBytes());
    }
    setState(() {});
  }

  // ================= SAVE PRODUCT =================
  Future<void> _saveProduct() async {
    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('يرجى إدخال جميع البيانات الأساسية وإضافة صورة واحدة على الأقل'),
        ),
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

    setState(() => _isLoading = true);

    try {
      final slug = _generateSlug(_nameController.text.trim());

      // ================= رفع الصورة الرئيسية =================
      final mainImageUrl = await StorageService().uploadProductImage(
        bytes: _images.first,
        fileName: 'product_main_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // ================= إنشاء المنتج =================
      final productId = await SupabaseService().createProductAndReturnId(
        name: _nameController.text.trim(),
        slug: slug,
        description: _descriptionController.text.trim(),
        price: price,
        imageUrl: mainImageUrl,
        categoryId: widget.categoryId, // ✅ القسم الصحيح
      );

      // ================= إضافة كل الصور للـ gallery =================
      for (int i = 0; i < _images.length; i++) {
        try {
          final imageUrl = i == 0
              ? mainImageUrl
              : await StorageService().uploadProductImage(
                  bytes: _images[i],
                  fileName:
                      'product_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
                );

          await SupabaseService().addProductImage(
            productId: productId,
            imageUrl: imageUrl,
          );
        } catch (e) {
          debugPrint('❌ فشل رفع صورة [$i]: $e');
        }
      }

      // ================= إضافة المقاسات (اختياري) =================
      for (final v in _variants) {
        final size = v.sizeController.text.trim();
        final qtyText = v.qtyController.text.trim();

        if (size.isEmpty || qtyText.isEmpty) continue;

        await SupabaseService().addProductVariant(
          productId: productId,
          size: size,
          quantity: int.parse(qtyText),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إنشاء المنتج بنجاح')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل إنشاء المنتج: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                'إضافة منتج جديد',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'السعر',
                  suffixText: 'YER',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('اختيار الصور'),
                ),
              ),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _images.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Stack(
                    children: [
                      Image.memory(
                        entry.value,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: Colors.red,
                          onPressed: () {
                            _images.removeAt(index);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المقاسات والكميات (اختياري)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _variants.add(_VariantRow());
                      setState(() {});
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة مقاس'),
                  ),
                ],
              ),

              ..._variants.map((v) {
                final index = _variants.indexOf(v);
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: v.sizeController,
                        decoration:
                            const InputDecoration(labelText: 'المقاس'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: v.qtyController,
                        decoration:
                            const InputDecoration(labelText: 'الكمية'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _variants.removeAt(index);
                        setState(() {});
                      },
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('حفظ المنتج'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= VARIANT HELPER =================
class _VariantRow {
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  void dispose() {
    sizeController.dispose();
    qtyController.dispose();
  }
}
