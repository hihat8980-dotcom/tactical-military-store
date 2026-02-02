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
      final fileName =
          "offer_${DateTime.now().millisecondsSinceEpoch}.png";

      // ✅ Upload Image To Supabase Storage
      final imageUrl = await service.uploadOfferImage(
        fileName: fileName,
        bytes: selectedImageBytes!,
      );

      // ✅ Insert Offer Into Database
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

      setState(() {});
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
    setState(() {});
  }

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

                    // ✅ Upload Button With Loading
                    ElevatedButton.icon(
                      onPressed: isUploading ? null : addOffer,
                      icon: isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
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
                future: service.getAllOffers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final offers = snapshot.data!;

                  if (offers.isEmpty) {
                    return const Center(
                      child: Text("لا توجد عروض حتى الآن"),
                    );
                  }

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
                          trailing: offer.isActive
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      disableOffer(offer.id),
                                )
                              : null,
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
