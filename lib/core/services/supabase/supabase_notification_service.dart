import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tactical_military_store/models/app_notification.dart';

class SupabaseNotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ جلب كل الإشعارات
  Future<List<AppNotification>> getNotifications() async {
    final res = await _supabase
        .from("notifications")
        .select()
        .order("created_at", ascending: false);

    return (res as List)
        .map((e) => AppNotification.fromMap(e))
        .toList();
  }

  // ✅ إرسال إشعار جديد (Super Admin)
  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    await _supabase.from("notifications").insert({
      "title": title,
      "body": body,
    });
  }
}
