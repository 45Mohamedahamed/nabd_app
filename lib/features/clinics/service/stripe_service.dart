import 'dart:convert';
import 'package:flutter/material.dart'; // ✅ حل مشكلة ThemeMode
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static Future<bool> makePayment({required String amount, required String currency}) async {
    try {
      // 1. نرسل المبلغ والعملة للسيرفر بتاعنا
      final response = await http.post(
        Uri.parse('https://your-server-url.com/payment-sheet'), 
        body: jsonEncode({
          'amount': amount,
          'currency': currency, // بنبعتها للسيرفر عشان هو اللي ينشئ الطلب بها
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      // 2. تهيئة واجهة الدفع
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['paymentIntent'],
          customerId: data['customer'],
          merchantDisplayName: 'Medical App Pro',
          // ❌ شيلنا currency من هنا لأن السيرفر اتصرف فيها خلاص
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: "US", testEnv: true),
          applePay: const PaymentSheetApplePay(merchantCountryCode: "US"),
          style: ThemeMode.system, // ✅ دلوقت هيتعرف عليها
        ),
      );

      // 3. عرض شاشة الدفع
      await Stripe.instance.presentPaymentSheet();
      
      return true;
    } catch (e) {
      debugPrint("خطأ في عملية الدفع: $e");
      return false;
    }
  }
}