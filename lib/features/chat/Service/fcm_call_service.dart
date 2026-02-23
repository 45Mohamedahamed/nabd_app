import 'dart:convert';
import 'package:http/http.dart' as http;

class FCMCallService {
  // 🔑 هتاخد الـ Server Key من Firebase Console -> Project Settings -> Cloud Messaging
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  static const String _serverKey = 'YOUR_FIREBASE_SERVER_KEY';

  static Future<void> sendCallSignal({
    required String targetToken, // توكن الدكتور
    required String callerName,  // اسم المريض
    required String chatId,      // رقم المحادثة
    required String callType,    // "VIDEO" أو "AUDIO"
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          "to": targetToken,
          "priority": "high", // 👈 ضروري جداً عشان الرنة توصل فوراً
          "content_available": true,
          "data": { // 👈 بنبعت البيانات هنا مش في notification عشان نتحكم في الرنة
            "type": "CALL_REQUEST",
            "callerName": callerName,
            "chatId": chatId,
            "callType": callType,
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          }
        }),
      );
      
      if (response.statusCode == 200) {
        print("✅ إشارة الرنين أُرسلت بنجاح");
      }
    } catch (e) {
      print("❌ فشل إرسال الإشارة: $e");
    }
  }
}