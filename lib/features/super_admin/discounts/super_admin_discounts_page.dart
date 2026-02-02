import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/theme/military_theme.dart';

// ✅ Offers Page Import
import 'package:tactical_military_store/features/super_admin/offers/offers_page.dart';

class SuperAdminDiscountsPage extends StatelessWidget {
  const SuperAdminDiscountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MilitaryTheme.sand,

      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '💸 إدارة الخصومات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // ================= INFO =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MilitaryTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MilitaryTheme.border),
              ),
              child: const Text(
                'من هنا يمكنك إدارة الخصومات والعروض\n'
                '• خصومات عامة\n'
                '• خصومات على المنتجات\n'
                '• خصومات على الأقسام\n'
                '• كوبونات الخصم\n'
                '• عروض البانر الرئيسية',
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= ACTIONS =================
            Expanded(
              child: GridView(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.05,
                ),
                children: [
                  _DiscountActionCard(
                    icon: Icons.percent_rounded,
                    title: 'خصم عام',
                    subtitle: 'على كل المتجر',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🚧 قريبًا: خصم عام"),
                        ),
                      );
                    },
                  ),

                  _DiscountActionCard(
                    icon: Icons.inventory_2_rounded,
                    title: 'خصم منتج',
                    subtitle: 'منتج محدد',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🚧 قريبًا: خصم منتج"),
                        ),
                      );
                    },
                  ),

                  _DiscountActionCard(
                    icon: Icons.category_rounded,
                    title: 'خصم قسم',
                    subtitle: 'قسم كامل',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🚧 قريبًا: خصم قسم"),
                        ),
                      );
                    },
                  ),

                  _DiscountActionCard(
                    icon: Icons.confirmation_number_rounded,
                    title: 'كوبونات',
                    subtitle: 'Codes',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🚧 قريبًا: كوبونات"),
                        ),
                      );
                    },
                  ),

                  // ✅ Banner Offers Card (Full Professional)
                  _DiscountActionCard(
                    icon: Icons.campaign_rounded,
                    title: "عروض البانر",
                    subtitle: "رفع صورة الخصم الرئيسية",
                    isSpecial: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OffersPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 🧱 Discount Action Card Widget
// =====================================================
class _DiscountActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// ✅ Special Card Highlight
  final bool isSpecial;

  const _DiscountActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSpecial
              ? MilitaryTheme.accent.withValues(alpha: 0.18)
              : MilitaryTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSpecial
                ? MilitaryTheme.accent
                : MilitaryTheme.border,
            width: isSpecial ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 5),
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: MilitaryTheme.sandDark,
              child: Icon(
                icon,
                color: isSpecial ? Colors.orangeAccent : MilitaryTheme.accent,
                size: 26,
              ),
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
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
