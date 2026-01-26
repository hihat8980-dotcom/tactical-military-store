import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/navigation/user_shell.dart';
import 'package:tactical_military_store/features/navigation/super_admin_shell.dart';

/// ✅ MainNavigation (Amazon Style)
/// --------------------------------
/// - المتجر مفتوح للجميع
/// - السلة/الطلبات/الحساب تحتاج Login
/// - Admin له لوحة تحكم
class MainNavigation extends StatelessWidget {
  final String role;

  /// ✅ هل المستخدم مسجل دخول؟
  final bool isLoggedIn;

  /// ✅ ماذا نفعل إذا حاول دخول صفحة محمية؟
  final VoidCallback onLoginRequired;

  const MainNavigation({
    super.key,
    required this.role,
    required this.isLoggedIn,
    required this.onLoginRequired,
  });

  @override
  Widget build(BuildContext context) {
    // 👑 Super Admin
    if (role == "super_admin") {
      return const SuperAdminShell();
    }

    // 🛡 Admin
    if (role == "admin") {
      return UserShell(
        isLoggedIn: isLoggedIn,
        onLoginRequired: onLoginRequired,
      );
    }

    // 👤 User أو Guest
    return UserShell(
      isLoggedIn: isLoggedIn,
      onLoginRequired: onLoginRequired,
    );
  }
}
