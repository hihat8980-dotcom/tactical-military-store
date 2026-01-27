import 'package:flutter/material.dart';

class CurrencyHelper {
  static String format(
    BuildContext context,
    double price,
  ) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return isArabic
        ? '${price.toInt()} ريال'
        : '${price.toInt()} YER';
  }
}
