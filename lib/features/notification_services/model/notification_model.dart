class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type; // medication_action, followup_action, info
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  // 👇 عشان الفايربيز مستقبلاً
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'time': time,
      'type': type,
      'isRead': isRead,
    };
  }
}