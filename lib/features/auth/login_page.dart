import 'package:flutter/material.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/core/services/token_service.dart';

import 'package:tactical_military_store/features/navigation/main_navigation.dart';
import 'package:tactical_military_store/features/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  // =====================================================
  // ✅ LOGIN FUNCTION
  // =====================================================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ✅ تسجيل الدخول من Supabase
      final result = await SupabaseService().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ حفظ التوكن
      await TokenService().saveToken(result.token);

      if (!mounted) return;

      // ✅ الانتقال حسب Role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigation(role: result.role),
        ),
      );
    } catch (e) {
      setState(() {
        _error = "❌ البريد أو كلمة المرور غير صحيحة";
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =====================================================
  // 🎨 Tactical Input Style
  // =====================================================
  InputDecoration _tacticalInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.greenAccent),
      filled: true,
      fillColor: const Color(0xFF1C222B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  // =====================================================
  // 🖥️ UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B0F14),
              Color(0xFF101820),
              Color(0xFF0B0F14),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFF141A22),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    color: Colors.black.withValues(alpha: 0.6),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🛡 Logo
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 75,
                        color: Colors.greenAccent,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Title
                    const Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "أدخل بياناتك للمتابعة داخل المتجر العسكري 🛒",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _tacticalInput(
                        "البريد الإلكتروني",
                        Icons.email_outlined,
                      ),
                      validator: (v) =>
                          v == null || !v.contains("@") ? "بريد غير صالح" : null,
                    ),

                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _tacticalInput(
                        "كلمة المرور",
                        Icons.lock_outline,
                      ),
                      validator: (v) =>
                          v == null || v.length < 6 ? "كلمة المرور قصيرة" : null,
                    ),

                    const SizedBox(height: 18),

                    // Error Box
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 18),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                "دخول المتجر",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "ليس لديك حساب؟",
                          style: TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "إنشاء حساب",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
