class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
