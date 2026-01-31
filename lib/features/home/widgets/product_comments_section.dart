import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';
import 'package:tactical_military_store/models/product_review.dart';

class ProductCommentsSection extends StatefulWidget {
  final int productId;
  final bool isSuperAdmin;

  const ProductCommentsSection({
    super.key,
    required this.productId,
    required this.isSuperAdmin,
  });

  @override
  State<ProductCommentsSection> createState() => _ProductCommentsSectionState();
}

class _ProductCommentsSectionState extends State<ProductCommentsSection> {
  late Future<List<ProductReview>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  // =====================================================
  // ✅ Load Reviews
  // =====================================================
  void _loadReviews() {
    _reviewsFuture = SupabaseService().getProductReviews(widget.productId);
  }

  // =====================================================
  // 🔄 Refresh Reviews
  // =====================================================
  Future<void> _refreshReviews() async {
    setState(() {
      _loadReviews();
    });

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // =====================================================
  // 🔒 Login Required Dialog
  // =====================================================
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text("🔒 تسجيل الدخول مطلوب"),
        content: const Text(
          "لا يمكنك كتابة تعليق إلا بعد تسجيل الدخول أو إنشاء حساب.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/login");
            },
            child: const Text("تسجيل الدخول"),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ⭐ Add Review Dialog
  // =====================================================
  void _openAddReviewDialog() {
    final commentController = TextEditingController();
    double rating = 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text("⭐ تقييم المنتج"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ⭐ Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        icon: Icon(
                          Icons.star,
                          color: i < rating
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                        onPressed: () {
                          setLocal(() => rating = i + 1);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ✍️ Comment
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "اكتب رأيك هنا...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  child: const Text("إرسال"),
                  onPressed: () async {
                    final text = commentController.text.trim();
                    if (text.isEmpty) return;

                    final messenger = ScaffoldMessenger.of(context);

                    Navigator.pop(dialogContext);

                    await SupabaseService().addProductReview(
                      productId: widget.productId,
                      comment: text,
                      rating: rating,
                    );

                    if (!mounted) return;

                    await _refreshReviews();

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("✅ تم إرسال التعليق بنجاح"),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // 🗑 Delete Review
  // =====================================================
  Future<void> _deleteReview(int reviewId) async {
    final messenger = ScaffoldMessenger.of(context);

    await SupabaseService().reviews.deleteReview(reviewId);

    if (!mounted) return;

    await _refreshReviews();

    messenger.showSnackBar(
      const SnackBar(content: Text("🗑 تم حذف التعليق")),
    );
  }

  // =====================================================
  // ⭐ Review Card
  // =====================================================
  Widget _buildReviewCard(ProductReview r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                r.nickname,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 16,
                    color:
                        i < r.rating ? Colors.amber : Colors.grey.shade300,
                  ),
                ),
              ),
              if (widget.isSuperAdmin)
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _deleteReview(r.id),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            r.comment,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                "💬 آراء العملاء",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.rate_review),
                label: const Text("أضف رأيك"),
                onPressed: () {
                  final user = SupabaseService().auth.currentUser;

                  if (user == null) {
                    _showLoginRequiredDialog();
                    return;
                  }

                  _openAddReviewDialog();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ Pull To Refresh مباشرة
          SizedBox(
            height: 380,
            child: RefreshIndicator(
              onRefresh: _refreshReviews,
              child: FutureBuilder<List<ProductReview>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("⭐ لا توجد تعليقات بعد"),
                        ),
                      ],
                    );
                  }

                  final reviews = snapshot.data!;

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      return _buildReviewCard(reviews[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
