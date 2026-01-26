import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/auth/login_page.dart';
import 'package:tactical_military_store/features/navigation/main_navigation.dart';

/// ✅ AppShell
/// ----------------------
/// هذا هو الغلاف الرئيسي للتطبيق
///
/// ✅ المتجر + السلة مفتوحة للجميع
/// ❌ فقط الدفع والشراء يحتاج تسجيل دخول
class AppShell extends StatelessWidget {
  final String role;

  /// هل المستخدم مسجل دخول؟
  final bool isLoggedIn;

  const AppShell({
    super.key,
    required this.role,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MainNavigation(
      role: role,
      isLoggedIn: isLoggedIn,

      // ✅ عند الحاجة لتسجيل الدخول (مثلاً عند الدفع)
      onLoginRequired: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );
      },
    );
  }
}
