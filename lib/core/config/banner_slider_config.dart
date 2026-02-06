import 'package:flutter/material.dart';

class BannerSliderConfig {
  static bool isEnabled = true;

  static bool enableAutoSlide = true;
  static Duration autoSlideDuration = const Duration(seconds: 15);
  static bool enableInfiniteLoop = true;

  static Duration animationDuration =
      const Duration(milliseconds: 700);
  static Curve animationCurve = Curves.easeInOut;

  static double bannerHeight = 170;
  static double horizontalMargin = 6;
  static double borderRadius = 20;

  static BoxFit imageFit = BoxFit.cover;
  static bool showLoadingIndicator = true;
  static bool showErrorIcon = true;
  static double errorIconSize = 42;
  static Color errorIconColor = Colors.white70;

  static bool enableGradientOverlay = true;
  static double gradientOpacity = 0.55;
  static Alignment gradientBegin = Alignment.bottomLeft;
  static Alignment gradientEnd = Alignment.topRight;

  static bool showTitleOverlay = true;
  static Alignment titleAlignment = Alignment.bottomLeft;
  static EdgeInsets titlePadding = const EdgeInsets.all(16);
  static Color titleColor = Colors.white;
  static double titleFontSize = 16;
  static FontWeight titleFontWeight = FontWeight.bold;

  static bool showIndicators = true;
  static double indicatorSize = 8;
  static double indicatorActiveWidth = 22;
  static double indicatorSpacing = 6;
  static Color indicatorColor = Colors.white38;
  static Color indicatorActiveColor = Colors.white;

  // =====================================================
  // APPLY SETTINGS FROM DATABASE
  // =====================================================
  static void applyFromDatabase(Map<String, dynamic> data) {
    isEnabled = data["is_enabled"] ?? true;
    enableAutoSlide = data["auto_slide"] ?? true;
    enableInfiniteLoop = data["infinite_loop"] ?? true;
    showIndicators = data["show_indicators"] ?? true;

    autoSlideDuration =
        Duration(seconds: data["slide_duration"] ?? 15);

    bannerHeight = (data["banner_height"] ?? 170).toDouble();
  }
}
