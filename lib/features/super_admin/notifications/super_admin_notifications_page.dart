import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase/supabase_notification_service.dart';

class SuperAdminNotificationsPage extends StatefulWidget {
  const SuperAdminNotificationsPage({super.key});

  @override
  State<SuperAdminNotificationsPage> createState() =>
      _SuperAdminNotificationsPageState();
}

class _SuperAdminNotificationsPageState
    extends State<SuperAdminNotificationsPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _loading = false;

  Future<void> _send() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) return;

    setState(() => _loading = true);

    await SupabaseNotificationService().sendNotification(
      title: _titleController.text,
      body: _bodyController.text,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم إرسال الإشعار بنجاح")),
    );

    _titleController.clear();
    _bodyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📢 إرسال إشعار"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "عنوان الإشعار",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _bodyController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "محتوى الإشعار",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _send,
                icon: const Icon(Icons.send),
                label: _loading
                    ? const CircularProgressIndicator()
                    : const Text("إرسال الإشعار"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
