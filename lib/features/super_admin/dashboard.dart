import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/super_admin/users/super_admin_users_page.dart';
import 'package:tactical_military_store/features/super_admin/categories/categories_page.dart';
import 'package:tactical_military_store/features/super_admin/orders/orders_page.dart';
import 'package:tactical_military_store/features/super_admin/contests/contests_dashboard_page.dart';

// ✅ الإشعارات
import 'package:tactical_military_store/features/notifications/super_admin_notifications_page.dart';

// ✅ إدارة المنتجات
import 'package:tactical_military_store/features/super_admin/products/super_admin_products_page.dart';

// ✅ الخصومات (الجديد)
import 'package:tactical_military_store/features/super_admin/discounts/super_admin_discounts_page.dart';

import 'package:tactical_military_store/core/theme/military_theme.dart';

class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryTheme.sand,

      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "👑 Super Admin Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 1.05,
          children: [
            // 👤 المستخدمون
            _DashboardCard(
              icon: Icons.people_alt_rounded,
              title: "المستخدمون",
              subtitle: "إدارة الحسابات والأدوار",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuperAdminUsersPage(),
                  ),
                );
              },
            ),

            // 🗂 الأقسام
            _DashboardCard(
              icon: Icons.category_rounded,
              title: "الأقسام",
              subtitle: "إدارة أقسام المتجر",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoriesPage(),
                  ),
                );
              },
            ),

            // 📦 المنتجات
            _DashboardCard(
              icon: Icons.inventory_2_rounded,
              title: "المنتجات",
              subtitle: "إضافة / تعديل / حذف",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuperAdminProductsPage(),
                  ),
                );
              },
            ),

            // 💸 الخصومات (الجديد)
            _DashboardCard(
              icon: Icons.local_offer_rounded,
              title: "الخصومات",
              subtitle: "إدارة العروض والتخفيضات",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuperAdminDiscountsPage(),
                  ),
                );
              },
            ),

            // 📦 الطلبات
            _DashboardCard(
              icon: Icons.shopping_cart_checkout_rounded,
              title: "الطلبات",
              subtitle: "إدارة طلبات العملاء",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrdersPage(),
                  ),
                );
              },
            ),

            // 🎯 المسابقات
            _DashboardCard(
              icon: Icons.emoji_events_rounded,
              title: "المسابقات",
              subtitle: "التحكم بالمسابقات والجوائز",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContestsDashboardPage(),
                  ),
                );
              },
            ),

            // 🔔 الإشعارات
            _DashboardCard(
              icon: Icons.notifications_active_rounded,
              title: "الإشعارات",
              subtitle: "إرسال إشعار لكل المستخدمين",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SuperAdminNotificationsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 🧱 Dashboard Card (Reusable)
// =====================================================
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: MilitaryTheme.card,
          border: Border.all(
            color: MilitaryTheme.border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 6),
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: MilitaryTheme.sandDark,
              child: Icon(
                icon,
                size: 30,
                color: MilitaryTheme.accent,
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
