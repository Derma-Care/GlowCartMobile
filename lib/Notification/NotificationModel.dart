class NotificationModel {
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false, // default to unread
  });
}
