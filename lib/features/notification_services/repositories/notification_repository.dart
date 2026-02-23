import 'package:flutter/foundation.dart';
import '../model/notification_model.dart'; // تأكد أن المسار يطابق مكان ملف الموديل عندك

class NotificationRepository {
  // 1. Singleton Pattern (عشان نضمن نسخة واحدة في التطبيق كله)
  static final NotificationRepository _instance = NotificationRepository._internal();
  factory NotificationRepository() => _instance;
  NotificationRepository._internal();

  // 2. قائمة الإشعارات (ValueNotifier عشان الشاشة تسمع أي تغيير)
  final ValueNotifier<List<NotificationModel>> notifications = ValueNotifier([]);

  // 3. دالة لإضافة إشعار جديد
  void addNotification(NotificationModel notif) {
    // بنضيف الجديد في الأول (Spread Operator)
    notifications.value = [notif, ...notifications.value];
  }

  // 4. ✅ دالة مسح الكل (التي كانت ناقصة)
  void clearAll() {
    notifications.value = []; // تصفير القائمة
  }
}