import 'dart:async';
import 'package:flutter/material.dart';

import 'package:tactical_military_store/features/navigation/app_shell.dart';
import 'package:tactical_military_store/core/services/token_service.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  String _image = 'assets/logo1.jpg';

  @override
  void initState() {
    super.initState();

    // ================= Animation =================
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // تغيير الصورة (اختياري)
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _image = 'assets/logo2.jpg';
      });
    });

    // الانتقال
    Timer(const Duration(seconds: 4), _goNext);
  }

  // =====================================================
  // 🚀 دخول المتجر (بدون تسجيل إجباري)
  // =====================================================
  Future<void> _goNext() async {
    final token = await TokenService().getToken();

    if (!mounted) return;

    // 👤 Guest
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AppShell(role: "guest"),
        ),
      );
      return;
    }

    // 👑 User / Admin / Super Admin
    final user = SupabaseService().currentUser;
    final role = user?.appMetadata['role'] as String? ?? "user";

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AppShell(role: role),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =====================================================
  // 🎨 UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F130E),
              Color(0xFF1F2A1F),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🛡 Logo
                  Image.asset(
                    _image,
                    width: 200,
                    height: 200,
                  ),

                  const SizedBox(height: 28),

                  // Title
                  const Text(
                    "TACTICAL MILITARY STORE",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      color: Color(0xFFE6E6E6),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  const Text(
                    "Prepared for the mission",
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.2,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
