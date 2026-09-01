class NotificationItemModel {
  NotificationItemModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.readAt,
    required this.severity,
    required this.topic,
  });

  final String id;
  final String title;
  final String body;
  final String createdAt;
  final String? readAt;
  final String severity;
  final String topic;

  bool get isRead => readAt != null;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Notification',
      body: json['body'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      readAt: json['read_at'] as String?,
      severity: json['severity'] as String? ?? 'info',
      topic: json['topic'] as String? ?? 'general',
    );
  }
}
