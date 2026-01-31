import 'package:flutter/material.dart';

class StoreSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final int notificationsCount;
  final VoidCallback onNotificationsTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onFilterTap;

  const StoreSearchBar({
    super.key,
    required this.onChanged,
    required this.notificationsCount,
    required this.onNotificationsTap,
    required this.onFavoritesTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 🔍 Search Field
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ],
            ),
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: "ابحث عن منتج...",
                prefixIcon: Icon(Icons.search, size: 20),
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ❤️ Favorites
        _IconBox(
          icon: Icons.favorite_border,
          onTap: onFavoritesTap,
        ),

        const SizedBox(width: 8),

        // 🎛 Filter
        _IconBox(
          icon: Icons.tune,
          onTap: onFilterTap,
        ),

        const SizedBox(width: 8),

        // 🔔 Notifications
        Stack(
          children: [
            _IconBox(
              icon: Icons.notifications_none,
              onTap: onNotificationsTap,
            ),
            if (notificationsCount > 0)
              Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: Colors.red,
                  child: Text(
                    "$notificationsCount",
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBox({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
