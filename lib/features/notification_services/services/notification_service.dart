import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart'; // 👈 ضروري للملاحة
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart'; // 👈 استيراد الكيانات لحل أخطاء AndroidParams
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';


// 🚨 معالج الخلفية: يجب أن يكون خارج الكلاس
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'CALL_REQUEST') {
    NotificationService.showIncomingCall(
      callerName: message.data['callerName'] ?? "طبيب غير معروف",
      callType: message.data['callType'] ?? "VIDEO",
      chatId: message.data['chatId'] ?? "0",
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 🔥 مفتاح الملاحة العالمي: بدونه لن يفتح التطبيق شاشة المكالمة عند الرد
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localNotifications.initialize(initSettings);

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 🎙️ بدء الاستماع لأحداث المكالمة (Accept / Decline)
    _listenToCallEvents();

    // 📡 الاستماع للإشعارات والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'CALL_REQUEST') {
        showIncomingCall(
          callerName: message.data['callerName'],
          callType: message.data['callType'],
          chatId: message.data['chatId'],
        );
      } else {
        _showLocalNotification(message);
      }
    });

    String? token = await _messaging.getToken();
    debugPrint("🚀 FCM Token: $token");
  }

  // 🔥 محرك مراقبة أحداث المكالمة
  void _listenToCallEvents() {
    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.event) {
        case Event.actionCallAccept:
          debugPrint("✅ تم الرد على المكالمة");
          // الملاحة لشاشة المكالمة فوراً
          navigatorKey.currentState?.pushNamed('/video_call'); 
          // ملاحظة: تأكد من تعريف Route باسم /video_call أو استخدم MaterialPageRoute مباشرة
          break;
        case Event.actionCallDecline:
          debugPrint("❌ تم رفض المكالمة");
          break;
        default:
          break;
      }
    });
  }

  // 2. محرك الرنين (تصحيح الأسماء لتجنب أخطاء Undefined)
  static Future<void> showIncomingCall({
    required String callerName, 
    required String callType, 
    required String chatId
  }) async {
    CallKitParams params = CallKitParams(
      id: chatId,
      nameCaller: callerName,
      appName: 'Medical App',
      avatar: 'https://i.pravatar.cc/100',
      type: callType == 'VIDEO' ? 1 : 0, 
      duration: 30000, 
      textAccept: 'رد',
      textDecline: 'رفض',
      extra: <String, dynamic>{'chatId': chatId},
      android: const AndroidParams( // 👈 تأكد من استيراد entities.dart لحل هذا السطر
        isCustomNotification: true,
        isShowFullLockedScreen: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#005DA3',
      ),
      ios: const IOSParams(
        supportsVideo: true,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  // 3. عرض إشعار Firebase العادي
  void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_channel_id', 'General Notifications',
      importance: Importance.max, priority: Priority.high,
    );
    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // 4. جدولة الأدوية (بدون تغيير)
  Future<void> scheduleMedication({
    required int baseId,
    required String medicineName,
    required String dosage,
    required int intervalHours,
    required int totalDays,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails('med_channel', 'Medication Alerts', importance: Importance.max, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );

    int dosesPerDay = (24 / intervalHours).floor();
    for (int i = 0; i < (dosesPerDay * totalDays); i++) {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(hours: intervalHours * (i + 1)));
      await _localNotifications.zonedSchedule(
        baseId + i, '💊 موعد الدواء', 'جرعة $medicineName ($dosage)',
        scheduledTime, notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // 5. إشعار فوري
  Future<void> showInstantNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails('instant_channel', 'Instant', importance: Importance.max, priority: Priority.high);
    await _localNotifications.show(DateTime.now().millisecond, title, body, const NotificationDetails(android: androidDetails));
  }

  Future<void> cancelAll() async => await _localNotifications.cancelAll();
}