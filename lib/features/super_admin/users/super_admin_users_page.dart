import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/app_user.dart';
import 'user_tile.dart';

class SuperAdminUsersPage extends StatefulWidget {
  const SuperAdminUsersPage({super.key});

  @override
  State<SuperAdminUsersPage> createState() => _SuperAdminUsersPageState();
}

class _SuperAdminUsersPageState extends State<SuperAdminUsersPage> {
  late Future<List<AppUser>> _usersFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _usersFuture = SupabaseService().getAllUsers();

    // 🔄 تحديث صامت كل 30 ثانية (بدون أي Loading أو وميض)
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _usersFuture = SupabaseService().getAllUsers();
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<AppUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمون'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 👤 بطاقة المستخدم (بدون Card داخل Card)
                    UserTile(
                      user: user,
                      onRoleChanged: (newRole) async {
                        await SupabaseService().updateUserRole(
                          userId: user.id,
                          role: newRole,
                        );

                        _usersFuture =
                            SupabaseService().getAllUsers();
                        setState(() {});
                      },
                    ),

                    // 🔐 صلاحية إضافة المنتجات (Admins فقط)
                    if (user.role == 'admin')
                      SwitchListTile(
                        title: const Text('السماح بإضافة المنتجات'),
                        subtitle:
                            const Text('التحكم بصلاحية إضافة منتج'),
                        value: user.canAddProducts,
                        onChanged: (val) async {
                          await SupabaseService()
                              .setAdminAddProductPermission(
                            userId: user.id,
                            value: val,
                          );

                          _usersFuture =
                              SupabaseService().getAllUsers();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
