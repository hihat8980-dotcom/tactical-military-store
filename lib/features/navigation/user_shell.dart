import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/home/store_home_page.dart';
import 'package:tactical_military_store/features/profile/profile_page.dart';
import 'package:tactical_military_store/features/super_admin/orders/user_orders_page.dart';
import 'package:tactical_military_store/features/settings/settings_page.dart';
import 'package:tactical_military_store/features/cart/cart_page.dart';

import 'package:tactical_military_store/core/theme/military_theme.dart';

/// ✅ UserShell (Fully Open Store)
/// --------------------------------
/// ✅ كل الصفحات مفتوحة
/// ✅ لا تسجيل دخول إجباري
/// ✅ تصميم متجر نظيف
class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;

  // =====================================================
  // ✅ Pages (ALL OPEN)
  // =====================================================
  /// ❌ لا تستخدم const list هنا لأن بعض الصفحات ليست const بالكامل
  late final List<Widget> _pages = [
    const StoreHomePage(), // 0 المتجر
    const CartPage(), // 1 السلة
    const UserOrdersPage(), // 2 الطلبات
    const ProfilePage(), // 3 الحساب
    const SettingsPage(), // 4 الإعدادات
  ];

  // =====================================================
  // ✅ UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryTheme.sand,

      // ❌ لا AppBar (واجهة مفتوحة)
      body: _pages[_index],

      // ================= Bottom Navigation =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,

        // ✅ تصميم ألوان المتجر
        selectedItemColor: MilitaryTheme.accent,
        unselectedItemColor: Colors.white60,
        backgroundColor: MilitaryTheme.card,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "المتجر",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "السلة",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "الطلبات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "الحساب",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "الإعدادات",
          ),
        ],
      ),
    );
  }
}
