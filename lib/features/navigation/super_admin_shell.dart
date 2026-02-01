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
  // ✅ Pages
  // =====================================================
  late final List<Widget> _pages = [
    const HomePage(),                // 🛍 المتجر (نفس المستخدم)
    const OrdersPage(),              // 📦 الطلبات
    const ProfilePage(),             // 👤 الحساب
    const SettingsPage(),            // ⚙️ الإعدادات
    const SuperAdminDashboardPage(), // 👑 لوحة التحكم
  ];

  // =====================================================
  // 🏷 Dynamic AppBar Title
  // =====================================================
  String get _title {
    if (_index == 4) {
      return "👑 لوحة تحكم السوبر أدمن";
    }
    return "🛍 Tactical Military Store";
  }

  // =====================================================
  // 🚪 Logout
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

      // ✅ Tactical AppBar (ذكي)
      appBar: AppBar(
        elevation: 6,
        backgroundColor: Colors.black,
        title: Text(
          _title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent,
            letterSpacing: 1.1,
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

      // ✅ Smooth Page Switch
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_index],
      ),

      // ✅ Bottom Navigation (موحّد)
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
