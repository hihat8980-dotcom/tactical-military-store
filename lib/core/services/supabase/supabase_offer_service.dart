import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tactical_military_store/models/store_offer.dart';

class SupabaseOfferService {
  final client = Supabase.instance.client;

  // =====================================================
  // ✅ Get Active Offer
  // =====================================================
  Future<StoreOffer?> getActiveOffer() async {
    final response = await client
        .from("offers")
        .select()
        .eq("is_active", true)
        .order("created_at", ascending: false)
        .limit(1);

    if (response.isEmpty) return null;

    return StoreOffer.fromMap(response.first);
  }

  // =====================================================
  // ✅ Get All Offers
  // =====================================================
  Future<List<StoreOffer>> getAllOffers() async {
    final response =
        await client.from("offers").select().order("created_at");

    return response.map((e) => StoreOffer.fromMap(e)).toList();
  }

  // =====================================================
  // ✅ Create Offer (Auto Activate)
  // =====================================================
  Future<void> createOffer({
    required String title,
    required String imageUrl,
  }) async {
    // ✅ Disable All Old Offers
    await client.from("offers").update({
      "is_active": false,
    });

    // ✅ Insert New Offer Active
    await client.from("offers").insert({
      "title": title,
      "image_url": imageUrl,
      "is_active": true,
    });
  }

  // =====================================================
  // ✅ Disable Offer
  // =====================================================
  Future<void> disableOffer(int id) async {
    await client.from("offers").update({
      "is_active": false,
    }).eq("id", id);
  }
}
