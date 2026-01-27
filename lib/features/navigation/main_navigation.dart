import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/navigation/user_shell.dart';
import 'package:tactical_military_store/features/navigation/super_admin_shell.dart';

/// ✅ MainNavigation
/// ---------------------------
/// - المتجر مفتوح للجميع
/// - لا يوجد تسجيل دخول إجباري
/// - جاهز للربط مع المسابقات لاحقًا
class MainNavigation extends StatelessWidget {
  final String role;

  const MainNavigation({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    // 👑 Super Admin
    if (role == "super_admin") {
      return const SuperAdminShell();
    }

    // 🛡 Admin / 👤 User / 👻 Guest
    return const UserShell();
  }
}
