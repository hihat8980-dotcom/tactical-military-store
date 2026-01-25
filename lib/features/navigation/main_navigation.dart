import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/navigation/user_shell.dart';
import 'package:tactical_military_store/features/navigation/super_admin_shell.dart';

class MainNavigation extends StatelessWidget {
  final String role;

  const MainNavigation({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    // 👑 سوبر أدمن
    if (role == "super_admin") {
      return const SuperAdminShell();
    }

    // 🛡 أدمن
    if (role == "admin") {
      return const UserShell();
    }

    // 👤 مستخدم عادي
    return const UserShell();
  }
}
