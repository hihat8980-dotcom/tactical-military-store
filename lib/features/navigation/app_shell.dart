import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/navigation/main_navigation.dart';

/// ✅ AppShell
/// ----------------------
/// الغلاف الرئيسي للتطبيق
/// - لا تسجيل دخول إجباري
/// - جاهز للربط لاحقًا (مسابقات / صلاحيات)
class AppShell extends StatelessWidget {
  final String role;

  const AppShell({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return MainNavigation(
      role: role,
    );
  }
}
