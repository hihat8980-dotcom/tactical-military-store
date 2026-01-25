import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tactical_military_store/core/services/storage_service.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

class CreateCategoryDialog extends StatefulWidget {
  const CreateCategoryDialog({super.key});

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
    });
  }

  // ================= SAVE CATEGORY =================
  Future<void> _saveCategory() async {
    if (_nameController.text.trim().isEmpty || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم القسم واختيار صورة'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // رفع صورة القسم
      final imageUrl = await StorageService().uploadCategoryImage(
        bytes: _imageBytes!,
        fileName:
            'category_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // إنشاء القسم في قاعدة البيانات
      await SupabaseService().createCategory(
        name: _nameController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إنشاء القسم: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إضافة قسم جديد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم القسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageBytes == null
                      ? const Center(
                          child: Text('اضغط لاختيار صورة'),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveCategory,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
