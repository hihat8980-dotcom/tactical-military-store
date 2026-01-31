import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final supabase = Supabase.instance.client;

  String name = "";
  String email = "";
  String phone = "";

  bool promoNotifications = true;
  bool darkMode = true;
  String currency = "YER";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPreferences();
  }

  // ===============================
  // ✅ Load User Data From Supabase
  // ===============================
  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    email = user.email ?? "";

    final data =
        await supabase.from("users").select().eq("id", user.id).single();

    if (!mounted) return;

    setState(() {
      name = data["name"] ?? "Tactical User";
      phone = data["phone"] ?? "No Phone";
    });
  }

  // ===============================
  // ✅ Load Local Preferences
  // ===============================
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      promoNotifications = prefs.getBool("promo_notifications") ?? true;
      darkMode = prefs.getBool("dark_mode") ?? true;
      currency = prefs.getString("currency") ?? "YER";
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) prefs.setBool(key, value);
    if (value is String) prefs.setString(key, value);
  }

  // ===============================
  // ✅ Open External Links
  // ===============================
  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ===============================
  // ✅ Edit Profile Dialog
  // ===============================
  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تعديل الحساب"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "الاسم"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "رقم الهاتف"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = supabase.auth.currentUser;
              if (user == null) return;

              await supabase.from("users").update({
                "name": nameController.text,
                "phone": phoneController.text,
              }).eq("id", user.id);

              if (!mounted) return;

              setState(() {
                name = nameController.text;
                phone = phoneController.text;
              });

              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // ===============================
  // ✅ Logout
  // ===============================
  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "⚙️ الإعدادات",
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ===============================
          // ✅ Profile Header (Legendary)
          // ===============================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF141A22),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.greenAccent,
                  child: Image.asset(
                    "assets/icon/app_icon.png",
                    height: 40,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white60),
                      ),
                      Text(
                        phone,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.greenAccent),
                  onPressed: _editProfile,
                )
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ===============================
          // ✅ Preferences
          // ===============================
          _sectionTitle("إعدادات المتجر"),

          _switchTile(
            title: "إشعارات العروض",
            value: promoNotifications,
            onChanged: (val) {
              setState(() => promoNotifications = val);
              _savePreference("promo_notifications", val);
            },
          ),

          _switchTile(
            title: "الوضع الليلي",
            value: darkMode,
            onChanged: (val) {
              setState(() => darkMode = val);
              _savePreference("dark_mode", val);
            },
          ),

          _dropdownTile(),

          const SizedBox(height: 25),

          // ===============================
          // ✅ Social Media (Ultra Pro)
          // ===============================
          _sectionTitle("تواصل معنا"),

          _socialButton(
            icon: FontAwesomeIcons.whatsapp,
            title: "WhatsApp Support",
            subtitle: "راسلنا مباشرة الآن",
            color: Colors.greenAccent,
            url: "https://wa.me/967770004140",
          ),

          _socialButton(
            icon: FontAwesomeIcons.instagram,
            title: "Instagram Store",
            subtitle: "@729cytac",
            color: Colors.pinkAccent,
            url: "https://instagram.com/729cytac",
          ),

          _socialButton(
            icon: FontAwesomeIcons.facebook,
            title: "Facebook Page",
            subtitle: "صفحتنا الرسمية",
            color: Colors.blueAccent,
            url:
                "https://www.facebook.com/profile.php?id=100092032081874&locale=ar_AR",
          ),

          const SizedBox(height: 25),

          // ===============================
          // ✅ Legal
          // ===============================
          _sectionTitle("القانون"),

          _simpleTile(
            title: "سياسة الخصوصية",
            onTap: () => _openLink("https://tactical729.com/privacy"),
          ),
          _simpleTile(
            title: "الشروط والأحكام",
            onTap: () => _openLink("https://tactical729.com/terms"),
          ),

          const SizedBox(height: 25),

          // ===============================
          // ✅ Logout Button
          // ===============================
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _logout,
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Center(
            child: Text(
              "© Tactical Military Store 2026",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 130),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // Widgets
  // ===============================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      value: value,
      activeThumbColor: Colors.greenAccent,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onChanged: onChanged,
    );
  }

  Widget _dropdownTile() {
    return ListTile(
      title: const Text("العملة", style: TextStyle(color: Colors.white)),
      subtitle: Text(currency, style: const TextStyle(color: Colors.white60)),
      trailing: DropdownButton<String>(
        dropdownColor: Colors.black,
        value: currency,
        items: const [
          DropdownMenuItem(value: "YER", child: Text("YER")),
          DropdownMenuItem(value: "SAR", child: Text("SAR")),
        ],
        onChanged: (val) {
          if (val == null) return;
          setState(() => currency = val);
          _savePreference("currency", val);
        },
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141A22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: FaIcon(icon, color: color),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.white60)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.white38),
        onTap: () => _openLink(url),
      ),
    );
  }

  Widget _simpleTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.white38),
      onTap: onTap,
    );
  }
}
