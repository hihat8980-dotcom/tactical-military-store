import 'package:flutter/material.dart';

class ContestsDashboardPage extends StatelessWidget {
  const ContestsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المسابقات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ContestCard(
            icon: Icons.settings,
            title: 'إعدادات المسابقات',
            subtitle: 'تفعيل / تعطيل – شروط – مدة المسابقة',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('إعدادات المسابقات قريبًا')),
              );
            },
          ),

          const SizedBox(height: 16),

          _ContestCard(
            icon: Icons.campaign,
            title: 'المسابقات الحالية',
            subtitle: 'إدارة المسابقات الفعّالة',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قائمة المسابقات قريبًا')),
              );
            },
          ),

          const SizedBox(height: 16),

          _ContestCard(
            icon: Icons.emoji_events,
            title: 'الفائزون',
            subtitle: 'عرض سجل الفائزين',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سجل الفائزين قريبًا')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContestCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContestCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
