import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBannerSettingsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getSettings() async {
    final data = await _client
        .from("banner_settings")
        .select()
        .eq("id", 1)
        .maybeSingle();

    if (data == null) {
      return {
        "is_enabled": true,
        "auto_slide": true,
        "infinite_loop": true,
        "show_indicators": true,
        "slide_duration": 15,
        "banner_height": 170,
      };
    }

    return Map<String, dynamic>.from(data);
  }

  Future<void> updateSettings({
    bool? isEnabled,
    bool? autoSlide,
    bool? infiniteLoop,
    int? slideDuration,
    bool? showIndicators,
    double? bannerHeight,
  }) async {
    final values = <String, dynamic>{};

    if (isEnabled != null) values["is_enabled"] = isEnabled;
    if (autoSlide != null) values["auto_slide"] = autoSlide;
    if (infiniteLoop != null) values["infinite_loop"] = infiniteLoop;
    if (slideDuration != null) values["slide_duration"] = slideDuration;
    if (showIndicators != null) values["show_indicators"] = showIndicators;
    if (bannerHeight != null) values["banner_height"] = bannerHeight;

    await _client.from("banner_settings").update(values).eq("id", 1);
  }
}
