import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ✅ تنظيف البريد وكلمة المرور بالكامل
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text.trim();
      final nickname = _nicknameController.text.trim();

      await SupabaseService().signUp(
        email: email,
        password: password,
        nickname: nickname,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "✅ تم إنشاء الحساب بنجاح، سجل دخولك الآن",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                    const Text(
                      "إنشاء حساب جديد",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _nicknameController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _tacticalInput("اسم المستخدم", Icons.person_outline),
                      validator: (v) =>
                          v == null || v.length < 3 ? "الاسم قصير جدًا" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _tacticalInput(
                          "البريد الإلكتروني", Icons.email_outlined),
                      validator: (v) {
                        if (v == null) return "أدخل البريد";
                        final email = v.trim();
                        final regex = RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
                        if (!regex.hasMatch(email)) {
                          return "البريد الإلكتروني غير صحيح";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _tacticalInput("كلمة المرور", Icons.lock_outline),
                      validator: (v) =>
                          v == null || v.length < 6 ? "كلمة المرور ضعيفة" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _tacticalInput(
                          "تأكيد كلمة المرور", Icons.lock_reset),
                      validator: (v) => v != _passwordController.text
                          ? "كلمة المرور غير متطابقة"
                          : null,
                    ),
                    const SizedBox(height: 18),

                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 18),

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
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                "إنشاء الحساب",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
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
