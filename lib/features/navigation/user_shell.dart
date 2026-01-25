import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/home/home_page.dart';
import 'package:tactical_military_store/features/auth/login_page.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

import 'package:tactical_military_store/features/profile/profile_page.dart';
import 'package:tactical_military_store/features/super_admin/orders/user_orders_page.dart';
import 'package:tactical_military_store/features/settings/settings_page.dart';

import 'package:tactical_military_store/features/cart/cart_page.dart';

import 'package:tactical_military_store/core/theme/military_theme.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _index = 0;

  // =====================================================
  // ✅ Pages (Store + Cart + Profile + Orders + Settings)
  // =====================================================
  late final List<Widget> _pages = [
    const HomePage(),
    const CartPage(),
    const ProfilePage(),
    const UserOrdersPage(),
    const SettingsPage(),
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
  // ✅ UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryTheme.sand,

      // ✅ AppBar سكري رسمي
      appBar: AppBar(
        title: const Text("🛡 Tactical Store"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          )
        ],
      ),

      // ✅ Body
      body: _pages[_index],

      // ✅ Bottom Navigation مثل Amazon
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
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
            icon: Icon(Icons.person),
            label: "حسابي",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "طلباتي",
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
