import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/store_offer.dart';

class StoreOffersBanner extends StatefulWidget {
  const StoreOffersBanner({super.key});

  @override
  State<StoreOffersBanner> createState() => _StoreOffersBannerState();
}

class _StoreOffersBannerState extends State<StoreOffersBanner> {
  final service = SupabaseService();

  late Future<StoreOffer?> _offerFuture;

  @override
  void initState() {
    super.initState();
    _offerFuture = service.getActiveOffer();
  }

  /// ✅ Refresh Banner After Upload
  void refreshBanner() {
    setState(() {
      _offerFuture = service.getActiveOffer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreOffer?>(
      future: _offerFuture,
      builder: (context, snapshot) {
        // ✅ Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.grey.shade200,
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ✅ No Offer Found
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }

        final offer = snapshot.data!;

        return Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: DecorationImage(
              image: NetworkImage(offer.imageUrl),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 5),
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                offer.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
