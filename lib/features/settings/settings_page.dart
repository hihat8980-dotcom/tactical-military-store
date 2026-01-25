import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "⚙️ الإعدادات",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: const Color(0xFF141A22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.dark_mode,
                    color: Colors.greenAccent),
                title: const Text(
                  "الوضع الليلي",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "التطبيق يعمل بتصميم عسكري مظلم",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Card(
              color: const Color(0xFF141A22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.security, color: Colors.greenAccent),
                title: const Text(
                  "الأمان والحماية",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "حسابك محمي بالكامل داخل النظام",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Card(
              color: const Color(0xFF141A22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.info, color: Colors.greenAccent),
                title: const Text(
                  "عن التطبيق",
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  "Tactical Military Store v1.0",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
