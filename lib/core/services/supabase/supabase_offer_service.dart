import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tactical_military_store/models/store_offer.dart';

class SupabaseOfferService {
  final SupabaseClient _client = Supabase.instance.client;

  // =====================================================
  // ✅ Get Active Offer (واحد فقط)
  // =====================================================
  Future<StoreOffer?> getActiveOffer() async {
    final data = await _client
        .from("offers")
        .select()
        .eq("is_active", true)
        .order("created_at", ascending: false)
        .limit(1);

    if (data.isEmpty) return null;

    return StoreOffer.fromMap(data.first);
  }

  // =====================================================
  // ✅ Get All Offers (للإدارة)
  // =====================================================
  Future<List<StoreOffer>> getAllOffers() async {
    final data = await _client
        .from("offers")
        .select()
        .order("created_at", ascending: false);

    return data.map((e) => StoreOffer.fromMap(e)).toList();
  }

  // =====================================================
  // ✅ Create New Offer
  // =====================================================
  Future<void> createOffer({
    required String title,
    required String imageUrl,
  }) async {
    await _client.from("offers").insert({
      "title": title,
      "image_url": imageUrl,
      "is_active": true,
    });
  }

  // =====================================================
  // ✅ Disable Offer
  // =====================================================
  Future<void> disableOffer(int id) async {
    await _client.from("offers").update({
      "is_active": false,
    }).eq("id", id);
  }
}
