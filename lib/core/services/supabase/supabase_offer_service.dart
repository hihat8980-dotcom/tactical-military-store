import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tactical_military_store/models/store_offer.dart';

class SupabaseOfferService {
  final SupabaseClient _client = Supabase.instance.client;

  // =====================================================
  // ✅ Get Single Active Offer (OLD – لا نكسره)
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
  // ✅ Get Multiple Active Offers (Slider + Time + Order)
  // =====================================================
  Future<List<StoreOffer>> getActiveOffers() async {
    final data = await _client
        .from("offers")
        .select()
        .eq("is_active", true)
        // start_at <= now OR start_at is null
        .or('start_at.is.null,start_at.lte.now()')
        // end_at >= now OR end_at is null
        .or('end_at.is.null,end_at.gte.now()')
        .order("sort_order", ascending: true)
        .order("created_at", ascending: false);

    final list = List<Map<String, dynamic>>.from(data);
    return list.map((e) => StoreOffer.fromMap(e)).toList();
  }

  // =====================================================
  // ✅ Get All Offers (Admin Panel)
  // =====================================================
  Future<List<StoreOffer>> getAllOffers() async {
    final data = await _client
        .from("offers")
        .select()
        .order("created_at", ascending: false);

    final list = List<Map<String, dynamic>>.from(data);
    return list.map((e) => StoreOffer.fromMap(e)).toList();
  }

  // =====================================================
  // ✅ Create Offer (افتراضيًا Active)
  // =====================================================
  Future<void> createOffer({
    required String title,
    required String imageUrl,
    int sortOrder = 0,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    await _client.from("offers").insert({
      "title": title,
      "image_url": imageUrl,
      "is_active": true,
      "sort_order": sortOrder,
      "start_at": startAt?.toIso8601String(),
      "end_at": endAt?.toIso8601String(),
    });
  }

  // =====================================================
  // ✅ Disable Offer (Soft Disable)
  // =====================================================
  Future<void> disableOffer(int id) async {
    await _client.from("offers").update({
      "is_active": false,
    }).eq("id", id);
  }

  // =====================================================
  // ✅ Update Sort Order (Drag & Drop)
  // =====================================================
  Future<void> updateSortOrder(int id, int order) async {
    await _client.from("offers").update({
      "sort_order": order,
    }).eq("id", id);
  }

  // =====================================================
  // ✅ Delete Offer + Delete Image From Storage
  // =====================================================
  Future<void> deleteOffer(StoreOffer offer) async {
    // 1️⃣ حذف الصورة من Storage
    try {
      final uri = Uri.parse(offer.imageUrl);
      final fileName = uri.pathSegments.last;

      await _client.storage.from("offers").remove([
        "banners/$fileName",
      ]);
    } catch (_) {}

    // 2️⃣ حذف السجل من DB
    await _client.from("offers").delete().eq("id", offer.id);
  }
}
