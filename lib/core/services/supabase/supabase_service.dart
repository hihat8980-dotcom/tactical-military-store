import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

// ================= MODELS =================
import 'package:tactical_military_store/models/app_user.dart';
import 'package:tactical_military_store/models/category.dart';
import 'package:tactical_military_store/models/product.dart';
import 'package:tactical_military_store/models/product_image.dart';
import 'package:tactical_military_store/models/product_variant.dart';
import 'package:tactical_military_store/models/product_review.dart';
import 'package:tactical_military_store/models/app_notification.dart';
import 'package:tactical_military_store/models/store_offer.dart';

// ================= SERVICES =================
import 'supabase_auth_service.dart';
import 'supabase_category_service.dart';
import 'supabase_product_service.dart';
import 'supabase_order_service.dart';
import 'supabase_review_contest_service.dart';

import 'package:tactical_military_store/core/services/supabase/supabase_notification_service.dart';
import 'package:tactical_military_store/core/services/supabase/supabase_offer_service.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // =====================================================
  // 🔌 SUB SERVICES
  // =====================================================
  final auth = SupabaseAuthService();
  final categories = SupabaseCategoryService();
  final products = SupabaseProductService();
  final orders = SupabaseOrderService();
  final reviews = SupabaseReviewContestService();
  final notifications = SupabaseNotificationService();

  // ✅ Offers Service
  final offers = SupabaseOfferService();

  // =====================================================
  // 🔐 AUTH
  // =====================================================

  Future<({String token, String role})> signIn({
    required String email,
    required String password,
  }) =>
      auth.signIn(email: email, password: password);

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
    String role = "user",
  }) =>
      auth.signUp(
        email: email,
        password: password,
        nickname: nickname,
        role: role,
      );

  Future<void> signOut() => auth.signOut();

  User? get currentUser => auth.currentUser;

  Future<AppUser?> getCurrentUserFromDatabase() =>
      auth.getCurrentUserFromDatabase();

  Future<List<AppUser>> getAllUsers() => auth.getAllUsers();

  Future<void> updateUserRole({
    required int userId,
    required String role,
  }) =>
      auth.updateUserRole(userId: userId, role: role);

  Future<void> setAdminAddProductPermission({
    required int userId,
    required bool value,
  }) =>
      auth.setAdminAddProductPermission(userId: userId, value: value);

  Future<void> updateLastSeen() => auth.updateLastSeen();

  // =====================================================
  // 📦 CATEGORIES
  // =====================================================

  Future<List<Category>> getCategories() => categories.getCategories();

  Future<void> createCategory({
    required String name,
    required String imageUrl,
  }) =>
      categories.createCategory(name: name, imageUrl: imageUrl);

  Future<void> updateCategory({
    required String id,
    required String name,
    required String imageUrl,
  }) =>
      categories.updateCategory(id: id, name: name, imageUrl: imageUrl);

  Future<void> deleteCategory(String id) => categories.deleteCategory(id);

  // =====================================================
  // 📦 PRODUCTS
  // =====================================================

  Future<int> createProductAndReturnId({
    required String name,
    required String slug,
    required String description,
    required double price,
    required String imageUrl,
    required int categoryId,
  }) =>
      products.createProductAndReturnId(
        name: name,
        slug: slug,
        description: description,
        price: price,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );

  Future<List<Product>> getAllProducts() => products.getAllProducts();

  Future<List<Product>> getProductsByCategory(int categoryId) =>
      products.getProductsByCategory(categoryId);

  Future<void> updateProduct({
    required int productId,
    required String name,
    required String slug,
    required String description,
    required double price,
    required String imageUrl,
    required int categoryId,
  }) =>
      products.updateProduct(
        productId: productId,
        name: name,
        slug: slug,
        description: description,
        price: price,
        imageUrl: imageUrl,
        categoryId: categoryId,
      );

  Future<void> deleteProduct(int productId) =>
      products.deleteProduct(productId);

  // =====================================================
  // 🖼 PRODUCT IMAGES
  // =====================================================

  Future<void> addProductImage({
    required int productId,
    required String imageUrl,
  }) =>
      products.addProductImage(productId: productId, imageUrl: imageUrl);

  Future<List<ProductImage>> getProductImages(int productId) =>
      products.getProductImages(productId);

  Future<void> deleteProductImage(int imageId) =>
      products.deleteProductImage(imageId);

  Future<List<String>> getProductImagesUrls(int productId) async {
    final images = await products.getProductImages(productId);
    return List<String>.from(images.map((e) => e.imageUrl));
  }

  // =====================================================
  // 📏 PRODUCT VARIANTS
  // =====================================================

  Future<void> addProductVariant({
    required int productId,
    required String size,
    required int quantity,
  }) =>
      products.addProductVariant(
        productId: productId,
        size: size,
        quantity: quantity,
      );

  Future<List<ProductVariant>> getProductVariants(int productId) =>
      products.getProductVariants(productId);

  Future<void> deleteProductVariant(int variantId) =>
      products.deleteProductVariant(variantId);

  // =====================================================
  // 🧾 ORDERS
  // =====================================================

  Future<void> createOrder({
    required int productId,
    required String productName,
    required String productImage,
    required String size,
    required int quantity,
    required double price,
    required String paymentMethod,
    required String phone,
  }) =>
      orders.createOrder(
        productId: productId,
        productName: productName,
        productImage: productImage,
        size: size,
        quantity: quantity,
        price: price,
        paymentMethod: paymentMethod,
        phone: phone,
      );

  Future<List<Map<String, dynamic>>> getAllOrders() =>
      orders.getAllOrders();

  Future<List<Map<String, dynamic>>> getUserOrdersByAuthId({
    required String authId,
  }) =>
      orders.getUserOrdersByAuthId(authId: authId);

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) =>
      orders.updateOrderStatus(orderId: orderId, status: status);

  // =====================================================
  // ⭐ REVIEWS
  // =====================================================

  Future<List<ProductReview>> getProductReviews(int productId) =>
      reviews.getProductReviews(productId);

  Future<void> addProductReview({
    required int productId,
    required String comment,
    required double rating,
  }) =>
      reviews.addProductReview(
        productId: productId,
        comment: comment,
        rating: rating,
      );

  Future<void> deleteReview(int reviewId) =>
      reviews.deleteReview(reviewId);

  // =====================================================
  // 🎯 CONTESTS
  // =====================================================

  Future<List<Map<String, dynamic>>> getContests() =>
      reviews.getContests();

  Future<void> createContest({
    required String title,
    required String description,
    DateTime? endDate,
  }) =>
      reviews.createContest(
        title: title,
        description: description,
        endDate: endDate,
      );

  Future<void> toggleContest({
    required int contestId,
    required bool isActive,
  }) =>
      reviews.toggleContest(
        contestId: contestId,
        isActive: isActive,
      );

  // =====================================================
  // 🔔 NOTIFICATIONS
  // =====================================================

  Future<List<AppNotification>> getNotifications() =>
      notifications.getNotifications();

  Future<void> sendNotification({
    required String title,
    required String body,
  }) =>
      notifications.sendNotification(title: title, body: body);

  Future<int> getNotificationsCount() async {
    final list = await notifications.getNotifications();
    return list.length;
  }

  // =====================================================
  // 🎁 OFFERS SYSTEM (Banner Offers)
  // =====================================================

  Future<StoreOffer?> getActiveOffer() => offers.getActiveOffer();

  Future<List<StoreOffer>> getAllOffers() => offers.getAllOffers();

  Future<void> createOffer({
    required String title,
    required String imageUrl,
  }) =>
      offers.createOffer(title: title, imageUrl: imageUrl);

  Future<void> disableOffer(int id) => offers.disableOffer(id);

  // =====================================================
  // ✅ Upload Offer Image To Supabase Storage (FINAL FIX ✅)
  // =====================================================

  Future<String> uploadOfferImage({
    required String fileName,
    required Uint8List bytes,
  }) async {
    const bucketName = "offers";

    final path = "banners/$fileName";

    await Supabase.instance.client.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: "image/png",
          ),
        );

    return Supabase.instance.client.storage
        .from(bucketName)
        .getPublicUrl(path);
  }
}
