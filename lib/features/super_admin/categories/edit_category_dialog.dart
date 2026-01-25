import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tactical_military_store/core/services/storage_service.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/category.dart';

class EditCategoryDialog extends StatefulWidget {
  final Category category;

  const EditCategoryDialog({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _nameController;
  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    try {
      String imageUrl = widget.category.imageUrl;

      if (_imageBytes != null) {
        final fileName =
            'category_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await StorageService().uploadCategoryImage(
          bytes: _imageBytes!,
          fileName: fileName,
        );
      }

      await SupabaseService().updateCategory(
        id: int.parse(widget.category.id),
        name: _nameController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تعديل القسم')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل القسم'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'اسم القسم'),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _imageBytes == null
                  ? const Center(child: Text('اختر صورة جديدة'))
                  : Image.memory(_imageBytes!, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? const CircularProgressIndicator()
              : const Text('حفظ'),
        ),
      ],
    );
  }
}
