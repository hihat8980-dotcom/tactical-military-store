import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/store_offer.dart';
import 'package:tactical_military_store/core/config/banner_slider_config.dart';

class StoreOffersBanner extends StatefulWidget {
  const StoreOffersBanner({super.key});

  @override
  State<StoreOffersBanner> createState() => _StoreOffersBannerState();
}

class _StoreOffersBannerState extends State<StoreOffersBanner> {
  final SupabaseService service = SupabaseService();

  final PageController _pageController = PageController();
  Timer? _timer;

  int _currentIndex = 0;
  bool _loading = true;
  List<StoreOffer> _offers = [];

  RealtimeChannel? _settingsChannel;

  // =====================================================
  @override
  void initState() {
    super.initState();
    _init();
  }

  // =====================================================
  Future<void> _init() async {
    await _loadSettings();
    await _loadOffers();
    _listenSettingsRealtime();
  }

  // =====================================================
  Future<void> _loadSettings() async {
    try {
      final data = await Supabase.instance.client
          .from("banner_settings")
          .select()
          .eq("id", 1)
          .maybeSingle();

      if (data != null) {
        BannerSliderConfig.isEnabled = data["is_enabled"] ?? true;
        BannerSliderConfig.enableAutoSlide = data["auto_slide"] ?? true;
        BannerSliderConfig.enableInfiniteLoop =
            data["infinite_loop"] ?? true;
        BannerSliderConfig.showIndicators =
            data["show_indicators"] ?? true;

        BannerSliderConfig.autoSlideDuration =
            Duration(seconds: data["slide_duration"] ?? 15);

        BannerSliderConfig.bannerHeight =
            (data["banner_height"] ?? 170).toDouble();
      }
    } catch (_) {}
  }

  // =====================================================
  void _listenSettingsRealtime() {
    _settingsChannel = Supabase.instance.client
        .channel("banner-settings")
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: "public",
          table: "banner_settings",
          callback: (payload) {
            final data = payload.newRecord;

            BannerSliderConfig.isEnabled = data["is_enabled"] ?? true;
            BannerSliderConfig.enableAutoSlide = data["auto_slide"] ?? true;
            BannerSliderConfig.enableInfiniteLoop =
                data["infinite_loop"] ?? true;
            BannerSliderConfig.showIndicators =
                data["show_indicators"] ?? true;

            BannerSliderConfig.autoSlideDuration =
                Duration(seconds: data["slide_duration"] ?? 15);

            BannerSliderConfig.bannerHeight =
                (data["banner_height"] ?? 170).toDouble();

            setState(() {});
            _startAutoSlide();
          },
        )
        .subscribe();
  }

  // =====================================================
  Future<void> _loadOffers() async {
    try {
      final data = await service.getActiveOffers();

      if (!mounted) return;

      setState(() {
        _offers = data;
        _loading = false;
      });

      _startAutoSlide();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // =====================================================
  void _startAutoSlide() {
    _timer?.cancel();

    if (!BannerSliderConfig.isEnabled ||
        !BannerSliderConfig.enableAutoSlide ||
        _offers.length <= 1) {
      return;
    }

    _timer = Timer.periodic(
      BannerSliderConfig.autoSlideDuration,
      (_) {
        if (!_pageController.hasClients) return;

        _currentIndex++;

        if (_currentIndex >= _offers.length) {
          if (BannerSliderConfig.enableInfiniteLoop) {
            _currentIndex = 0;
          } else {
            _timer?.cancel();
            return;
          }
        }

        _pageController.animateToPage(
          _currentIndex,
          duration: BannerSliderConfig.animationDuration,
          curve: BannerSliderConfig.animationCurve,
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _settingsChannel?.unsubscribe();
    super.dispose();
  }

  // =====================================================
  Widget _buildIndicators() {
    if (!BannerSliderConfig.showIndicators || _offers.length <= 1) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_offers.length, (index) {
        final active = _currentIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(
            horizontal: BannerSliderConfig.indicatorSpacing,
          ),
          width: active
              ? BannerSliderConfig.indicatorActiveWidth
              : BannerSliderConfig.indicatorSize,
          height: BannerSliderConfig.indicatorSize,
          decoration: BoxDecoration(
            color: active
                ? BannerSliderConfig.indicatorActiveColor
                : BannerSliderConfig.indicatorColor,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  // =====================================================
  @override
  Widget build(BuildContext context) {
    if (!BannerSliderConfig.isEnabled) {
      return const SizedBox();
    }

    if (_loading) {
      return SizedBox(
        height: BannerSliderConfig.bannerHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_offers.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        SizedBox(
          height: BannerSliderConfig.bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _offers.length,
            onPageChanged: (i) {
              setState(() => _currentIndex = i);
            },
            itemBuilder: (context, index) {
              final offer = _offers[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(
                  BannerSliderConfig.borderRadius,
                ),
                child: Image.network(
                  offer.imageUrl,
                  fit: BannerSliderConfig.imageFit,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildIndicators(),
      ],
    );
  }
}
