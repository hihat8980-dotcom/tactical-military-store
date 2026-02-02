import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/category.dart';

import 'create_category_dialog.dart';
import 'edit_category_dialog.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Category>> _future;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = SupabaseService().getCategories();
  }

  // ================= 🗑 حذف قسم =================
  Future<void> _deleteCategory(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف القسم'),
        content: Text('هل تريد حذف قسم "${category.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // ✅ UUID → String (بدون int.parse)
    await SupabaseService().deleteCategory(category.id);

    _hasChanges = true;
    setState(_reload);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم حذف القسم بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ================= ✏️ تعديل قسم =================
  Future<void> _editCategory(Category category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditCategoryDialog(category: category),
    );

    if (result == true) {
      _hasChanges = true;
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الأقسام'),
          centerTitle: true,
        ),
        body: FutureBuilder<List<Category>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = snapshot.data ?? [];
            if (categories.isEmpty) {
              return const Center(child: Text('لا توجد أقسام'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 32,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final c = categories[index];

                return Column(
                  children: [
                    Text(
                      c.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage(c.imageUrl),
                        ),

                        // ✏️ Edit
                        Positioned(
                          top: -6,
                          left: -6,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.edit, size: 14),
                              color: Colors.white,
                              onPressed: () => _editCategory(c),
                            ),
                          ),
                        ),

                        // 🗑 Delete
                        Positioned(
                          top: -6,
                          right: -6,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.red,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete, size: 14),
                              color: Colors.white,
                              onPressed: () => _deleteCategory(c),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('إضافة قسم'),
          onPressed: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => const CreateCategoryDialog(),
            );

            if (result == true) {
              _hasChanges = true;
              setState(_reload);
            }
          },
        ),
      ),
    );
  }
}
