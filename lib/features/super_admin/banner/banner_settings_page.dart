import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/config/banner_slider_config.dart';
import 'package:tactical_military_store/core/services/supabase/supabase_banner_settings_service.dart';

class BannerSettingsPage extends StatefulWidget {
  const BannerSettingsPage({super.key});

  @override
  State<BannerSettingsPage> createState() => _BannerSettingsPageState();
}

class _BannerSettingsPageState extends State<BannerSettingsPage> {
  final SupabaseBannerSettingsService _service =
      SupabaseBannerSettingsService();

  bool _loading = true;

  bool isEnabled = true;
  bool autoSlide = true;
  bool infiniteLoop = true;
  bool showIndicators = true;

  int slideDurationSeconds = 15;
  double bannerHeight = 160;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // =====================================================
  // LOAD SETTINGS
  // =====================================================
  Future<void> _loadSettings() async {
    final data = await _service.getSettings();

    isEnabled = data['is_enabled'] ?? true;
    autoSlide = data['auto_slide'] ?? true;
    infiniteLoop = data['infinite_loop'] ?? true;
    showIndicators = data['show_indicators'] ?? true;
    slideDurationSeconds = data['slide_duration'] ?? 15;
    bannerHeight = (data['banner_height'] ?? 160).toDouble();

    BannerSliderConfig.applyFromDatabase(data);

    setState(() => _loading = false);
  }

  // =====================================================
  // AUTO SAVE
  // =====================================================
  Future<void> _autoSave() async {
    await _service.updateSettings(
      isEnabled: isEnabled,
      autoSlide: autoSlide,
      infiniteLoop: infiniteLoop,
      slideDuration: slideDurationSeconds,
      showIndicators: showIndicators,
      bannerHeight: bannerHeight,
    );

    BannerSliderConfig.isEnabled = isEnabled;
    BannerSliderConfig.enableAutoSlide = autoSlide;
    BannerSliderConfig.enableInfiniteLoop = infiniteLoop;
    BannerSliderConfig.showIndicators = showIndicators;
    BannerSliderConfig.autoSlideDuration =
        Duration(seconds: slideDurationSeconds);
    BannerSliderConfig.bannerHeight = bannerHeight;
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إعدادات البانر"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _switch("تفعيل البانر", isEnabled, (v) {
                  setState(() => isEnabled = v);
                  _autoSave();
                }),
                _switch("تحريك تلقائي", autoSlide, (v) {
                  setState(() => autoSlide = v);
                  _autoSave();
                }),
                _switch("تكرار لا نهائي", infiniteLoop, (v) {
                  setState(() => infiniteLoop = v);
                  _autoSave();
                }),
                _switch("إظهار المؤشرات", showIndicators, (v) {
                  setState(() => showIndicators = v);
                  _autoSave();
                }),

                const SizedBox(height: 20),

                const Text("مدة تغيير الصورة"),
                Slider(
                  min: 5,
                  max: 60,
                  divisions: 11,
                  value: slideDurationSeconds.toDouble(),
                  onChanged: (v) {
                    setState(() => slideDurationSeconds = v.toInt());
                    _autoSave();
                  },
                ),

                const SizedBox(height: 20),

                const Text("ارتفاع البانر"),
                Slider(
                  min: 120,
                  max: 300,
                  divisions: 9,
                  value: bannerHeight,
                  onChanged: (v) {
                    setState(() => bannerHeight = v);
                    _autoSave();
                  },
                ),
              ],
            ),
    );
  }

  Widget _switch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (v) => onChanged(v),
    );
  }
}
