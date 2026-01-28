import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/auth/login_page.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService().currentUser;

    // ============================
    // ✅ Guest (Not Logged In)
    // ============================
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("الحساب"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 95,
                color: Colors.grey,
              ),
              const SizedBox(height: 18),

              const Text(
                "أضف حسابك الآن",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "سجل دخولك للاستفادة من الطلبات والعروض والخصومات",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),

              // ✅ زر واحد فقط
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "تسجيل الدخول / إنشاء حساب",
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ============================
    // ✅ Logged In User
    // ============================
    return Scaffold(
      appBar: AppBar(
        title: const Text("حسابي"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.person, size: 50),
            ),

            const SizedBox(height: 14),

            Text(
              user.email ?? "مستخدم",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "تم تسجيل الدخول بنجاح ✅",
              style: TextStyle(
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            // زر تسجيل خروج
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                icon: const Icon(Icons.logout),
                label: const Text("تسجيل الخروج"),
                onPressed: () async {
                  await SupabaseService().signOut();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
