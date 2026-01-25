import 'package:flutter/material.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/features/auth/login_page.dart';

import 'package:tactical_military_store/features/home/home_page.dart';
import 'package:tactical_military_store/features/profile/profile_page.dart';
import 'package:tactical_military_store/features/settings/settings_page.dart';

import 'package:tactical_military_store/features/super_admin/orders/orders_page.dart';
import 'package:tactical_military_store/features/super_admin/dashboard.dart';

class SuperAdminShell extends StatefulWidget {
  const SuperAdminShell({super.key});

  @override
  State<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends State<SuperAdminShell> {
  int _index = 0;

  // =====================================================
  // ✅ Pages (Store + Orders + Profile + Settings + Admin)
  // =====================================================
  late final List<Widget> _pages = [
    const HomePage(),
    const OrdersPage(),
    const ProfilePage(),
    const SettingsPage(),
    const SuperAdminDashboardPage(),
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
      (_) => false,
    );
  }

  // =====================================================
  // 🖥 UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      // ✅ Tactical AppBar
      appBar: AppBar(
        elevation: 6,
        backgroundColor: Colors.black,
        title: const Text(
          "👑 Super Admin Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "تسجيل خروج",
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),

      // ✅ Smooth Page Switch Animation
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_index],
      ),

      // ✅ Tactical Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.greenAccent.withValues(alpha: 0.15),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (value) => setState(() => _index = value),

          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,

          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white54,

          selectedFontSize: 13,
          unselectedFontSize: 12,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: "المتجر",
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
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: "لوحة التحكم",
            ),
          ],
        ),
      ),
    );
  }
}
