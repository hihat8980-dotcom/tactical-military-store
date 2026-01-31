import 'package:flutter/material.dart';

/// ✅ أنواع ترتيب المنتجات
enum ProductSortType {
  newest,
  priceLow,
  priceHigh,
}

/// =======================================================
/// ✅ Premium Filters Bottom Sheet (Flutter 3.32+ Safe)
/// =======================================================
class StoreFiltersSheet extends StatefulWidget {
  final ProductSortType selectedSort;
  final ValueChanged<ProductSortType> onApply;

  const StoreFiltersSheet({
    super.key,
    required this.selectedSort,
    required this.onApply,
  });

  @override
  State<StoreFiltersSheet> createState() => _StoreFiltersSheetState();
}

class _StoreFiltersSheetState extends State<StoreFiltersSheet> {
  late ProductSortType _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================= HEADER =================
          Container(
            width: 45,
            height: 5,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const Text(
            "🎛 ترتيب المنتجات",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          // ================= RADIO GROUP =================
          RadioGroup<ProductSortType>(
            groupValue: _current,
            onChanged: (value) {
              if (value != null) {
                setState(() => _current = value);
              }
            },
            child: Column(
              children: [
                _FilterTile(
                  title: "🆕 الأحدث أولاً",
                  value: ProductSortType.newest,
                ),
                _FilterTile(
                  title: "💰 الأرخص أولاً",
                  value: ProductSortType.priceLow,
                ),
                _FilterTile(
                  title: "🔥 الأغلى أولاً",
                  value: ProductSortType.priceHigh,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ================= APPLY BUTTON =================
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                widget.onApply(_current);
                Navigator.pop(context);
              },
              child: const Text(
                "✅ تطبيق الفلاتر",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// =======================================================
/// ✅ Tile Widget for each Filter Option
/// =======================================================
class _FilterTile extends StatelessWidget {
  final String title;
  final ProductSortType value;

  const _FilterTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ProductSortType>(
      value: value,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      activeColor: Colors.black,
    );
  }
}
