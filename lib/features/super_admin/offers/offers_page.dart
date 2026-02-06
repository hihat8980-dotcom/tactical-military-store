import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/store_offer.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final service = SupabaseService();

  final titleController = TextEditingController();

  Uint8List? selectedImageBytes;
  bool isUploading = false;

  // ✅ Future محفوظ لتجنب التحميل المتكرر
  late Future<List<StoreOffer>> _offersFuture;

  @override
  void initState() {
    super.initState();
    _offersFuture = service.getAllOffers();
  }

  // ✅ Refresh Offers
  void refreshOffers() {
    setState(() {
      _offersFuture = service.getAllOffers();
    });
  }

  // =====================================================
  // ✅ Pick Image From Device
  // =====================================================
  Future<void> pickOfferImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;

    setState(() {
      selectedImageBytes = result.files.first.bytes;
    });
  }

  // =====================================================
  // ✅ Upload + Create Offer
  // =====================================================
  Future<void> addOffer() async {
    if (titleController.text.isEmpty || selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ أدخل العنوان واختر صورة")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final fileName = "offer_${DateTime.now().millisecondsSinceEpoch}.png";

      final imageUrl = await service.uploadOfferImage(
        fileName: fileName,
        bytes: selectedImageBytes!,
      );

      await service.createOffer(
        title: titleController.text,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      titleController.clear();
      selectedImageBytes = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم رفع العرض بنجاح")),
      );

      // ✅ Refresh List بعد الإضافة
      refreshOffers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ خطأ أثناء الرفع: $e")),
      );
    }

    setState(() => isUploading = false);
  }

  // =====================================================
  // ✅ Disable Offer
  // =====================================================
  Future<void> disableOffer(int id) async {
    await service.disableOffer(id);
    refreshOffers();
  }

  // =====================================================
  // ✅ Delete Offer
  // =====================================================
  Future<void> deleteOffer(StoreOffer offer) async {
    await service.deleteOffer(offer);
    refreshOffers();
  }

  // =====================================================
  // ✅ UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎁 إدارة عروض البانر"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= ADD OFFER =================
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "عنوان العرض",
                        prefixIcon: Icon(Icons.discount),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: pickOfferImage,
                      icon: const Icon(Icons.image),
                      label: const Text("اختيار صورة من الجهاز"),
                    ),

                    const SizedBox(height: 10),

                    if (selectedImageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          selectedImageBytes!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: isUploading ? null : addOffer,
                      icon: isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        isUploading ? "جاري رفع العرض..." : "رفع العرض",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ================= OFFERS LIST =================
            Expanded(
              child: FutureBuilder<List<StoreOffer>>(
                future: _offersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("لا توجد عروض حتى الآن"),
                    );
                  }

                  final offers = snapshot.data!;

                  return ListView.builder(
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(offer.imageUrl),
                          ),
                          title: Text(offer.title),
                          subtitle: Text(
                            offer.isActive ? "✅ مفعل" : "❌ غير مفعل",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.cancel,
                                    color: Colors.orange),
                                onPressed: () => disableOffer(offer.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () => deleteOffer(offer),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
