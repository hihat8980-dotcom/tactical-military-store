import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tactical_military_store/models/store_offer.dart';

class SupabaseOfferService {
  final SupabaseClient _client = Supabase.instance.client;

  // =====================================================
  // 🌐 Detect Web
  // =====================================================
  bool get _isWeb => kIsWeb;

  // =====================================================
  // 🌐 Proxy GET (للويب فقط)
  // =====================================================
  Future<List<dynamic>> _proxyGet(String table) async {
    final response = await http.get(Uri.parse("/api/$table"));

    if (response.statusCode != 200) {
      throw Exception("Proxy error");
    }

    return jsonDecode(response.body);
  }

  // =====================================================
  // ✅ Get Single Active Offer (OLD – لا نكسره)
  // =====================================================
  Future<StoreOffer?> getActiveOffer() async {
    if (_isWeb) {
      final data = await _proxyGet("offers");

      if (data.isEmpty) return null;
      return StoreOffer.fromMap(data.first);
    }

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
    if (_isWeb) {
      final data = await _proxyGet("offers");
      return List<Map<String, dynamic>>.from(data)
          .map((e) => StoreOffer.fromMap(e))
          .toList();
    }

    final data = await _client
        .from("offers")
        .select()
        .eq("is_active", true)
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
  // ✅ Create Offer
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
  // ✅ Disable Offer
  // =====================================================
  Future<void> disableOffer(int id) async {
    await _client.from("offers").update({
      "is_active": false,
    }).eq("id", id);
  }

  // =====================================================
  // ✅ Update Sort Order
  // =====================================================
  Future<void> updateSortOrder(int id, int order) async {
    await _client.from("offers").update({
      "sort_order": order,
    }).eq("id", id);
  }

  // =====================================================
  // ✅ Delete Offer
  // =====================================================
  Future<void> deleteOffer(StoreOffer offer) async {
    try {
      final uri = Uri.parse(offer.imageUrl);
      final fileName = uri.pathSegments.last;

      await _client.storage.from("offers").remove([
        "banners/$fileName",
      ]);
    } catch (_) {}

    await _client.from("offers").delete().eq("id", offer.id);
  }
}
