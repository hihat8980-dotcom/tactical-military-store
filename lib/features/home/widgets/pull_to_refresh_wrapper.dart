import 'package:flutter/material.dart';

/// ✅ Widget عالمي لميزة Pull To Refresh
/// تستخدمه في أي صفحة بسهولة مثل Amazon
class PullToRefreshWrapper extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefreshWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
