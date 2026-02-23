import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 👇 استدعاء ملفات مشروعك
import 'features/intro/ui/splash_screen.dart';
import 'features/pharmacy/service/cart_provider.dart';
import 'features/notification_services/services/notification_service.dart'; // 👈 تأكد من وجود الملف الذي أنشأناه سابقاً

// --------------------------------------------------------------------
// 🚨 معالج إشعارات الخلفية (Background Handler)
// يجب أن يكون خارج أي كلاس وفي أعلى الملف لضمان استجابة النظام وهو مغلق
// --------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // إذا كان الإشعار طلب مكالمة، أظهر شاشة الرنين فوراً
  if (message.data['type'] == 'CALL_REQUEST') {
    NotificationService.showIncomingCall(
      callerName: message.data['callerName'] ?? "طبيب غير معروف",
      callType: message.data['callType'] ?? "VIDEO",
      chatId: message.data['chatId'] ?? "0",
    );
  }
}

// --------------------------------------------------------------------
// 🚀 نقطة انطلاق التطبيق (Main)
// --------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. تهيئة الفايربيز
    await Firebase.initializeApp();
    print("Firebase Connected ✅");

    // 2. ربط معالج إشعارات الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. تهيئة خدمة الإشعارات الشاملة (المكالمات، الأدوية، الدردشة)
    await NotificationService().init();
    
  } catch (e) {
    print("Firebase Error ❌: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // أضف أي Providers أخرى هنا
      ],
      child: const NabdApp(),
    ),
  );
}

class NabdApp extends StatelessWidget {
  const NabdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          // 🔥 أهم سطر لربط الرد على المكالمة بفتح الشاشة تلقائياً
          navigatorKey: NotificationService.navigatorKey, 
          
          debugShowCheckedModeBanner: false,
          title: 'Nabd Medical App',
          theme: ThemeData(
            primaryColor: const Color(0xFF005DA3),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF005DA3),
              primary: const Color(0xFF005DA3),
            ),
          ),
          // يمكنك إضافة الـ Routes هنا لتسهيل التنقل
          routes: {
            '/': (context) => const SplashScreen(),
            // '/video_call': (context) => const VideoCallScreen(),
          },
          initialRoute: '/',
        );
      },
    );
  }
}