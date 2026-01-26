import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/home/home_page.dart';
import 'package:tactical_military_store/features/auth/login_page.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

import 'package:tactical_military_store/features/profile/profile_page.dart';
import 'package:tactical_military_store/features/super_admin/orders/user_orders_page.dart';
import 'package:tactical_military_store/features/settings/settings_page.dart';

import 'package:tactical_military_store/features/cart/cart_page.dart';

import 'package:tactical_military_store/core/theme/military_theme.dart';

/// ✅ UserShell (Amazon Style)
/// --------------------------------
/// ✅ المتجر مفتوح للجميع
/// ✅ السلة مفتوحة للجميع
/// ❌ الطلبات والحساب تحتاج تسجيل دخول
class UserShell extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback onLoginRequired;

  const UserShell({
    super.key,
    required this.isLoggedIn,
    required this.onLoginRequired,
  });

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;

  // =====================================================
  // ✅ Pages
  // =====================================================
  late final List<Widget> _pages = [
    const HomePage(),        // 0 متجر
    const CartPage(),        // 1 سلة (مفتوحة للجميع)
    const UserOrdersPage(),  // 2 طلباتي (Login Required)
    const ProfilePage(),     // 3 حسابي (Login Required)
    const SettingsPage(),    // 4 إعدادات (Login Required)
  ];

  // =====================================================
  // ✅ Logout
  // =====================================================
  Future<void> _logout() async {
    await SupabaseService().signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // =====================================================
  // ✅ Navigation Logic
  // =====================================================
  void _onTabTapped(int value) {
    /// الصفحات التي تحتاج تسجيل دخول:
    /// الطلبات + الحساب + الإعدادات
    if ((value == 2 || value == 3 || value == 4) &&
        !widget.isLoggedIn) {
      widget.onLoginRequired();
      return;
    }

    setState(() => _index = value);
  }

  // =====================================================
  // ✅ UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryTheme.sand,

      // ================= AppBar =================
      appBar: AppBar(
        title: const Text("🛡 Tactical Store"),

        actions: [
          // ✅ Logout يظهر فقط لو مسجل دخول
          if (widget.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: _logout,
            ),
        ],
      ),

      // ================= Body =================
      body: _pages[_index],

      // ================= Bottom Nav =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTabTapped,
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
            label: "طلباتي",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "حسابي",
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
