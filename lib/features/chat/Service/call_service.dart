import 'dart:convert';
import 'package:http/http.dart' as http;

class CallService {
  // المفتاح ده بتجيبه من Firebase Console -> Project Settings -> Cloud Messaging
  static const String _serverKey = "YOUR_SERVER_KEY"; 

  static Future<void> sendCallSignal({
    required String targetToken, // توكن الطبيب (المستقبل)
    required String callerName,
    required String chatId,
    required String callType, // "VIDEO" or "AUDIO"
  }) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          "to": targetToken,
          "priority": "high", // 👈 ضروري عشان الإشعار يوصل فوراً
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "type": "CALL",
            "callType": callType,
            "callerName": callerName,
            "chatId": chatId,
          }
        }),
      );
    } catch (e) {
      print("Error sending call signal: $e");
    }
  }
}