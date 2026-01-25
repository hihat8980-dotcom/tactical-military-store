import 'package:flutter/material.dart';
import 'main_navigation.dart';

/// AppShell
/// ----------------------
/// هذا الملف هو غلاف التنقّل الحقيقي (Navigator)
/// وظيفته فقط:
/// - إنشاء Navigator واحد
/// - وضع MainNavigation بداخله
/// - تمكين Navigator.push داخل HomePage وباقي الصفحات
class AppShell extends StatelessWidget {
  final String role;

  const AppShell({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MainNavigation(role: role),
        );
      },
    );
  }
}
