import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 1. مكتبة الفايربيز

// 👇 2. تأكد من مسارات الصفحات دي تكون صحيحة عندك
import '../../onboarding/ui/onboarding_screen.dart'; 
import '../../core/layout/main_layout.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // المؤقت لمدة 3 ثواني
    Timer(const Duration(seconds: 3), () {
      _checkUserAndNavigate();
    });
  }

  // 🛠️ دالة الفحص والتوجيه
  void _checkUserAndNavigate() {
    // جلب المستخدم الحالي
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return; // تأكد أن الشاشة مازالت موجودة

    if (user != null) {
      // ✅ مسجل دخول -> روح للرئيسية فوراً
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (c) => const MainLayout())
      );
    } else {
      // ❌ غير مسجل -> روح للشرح (Onboarding)
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (c) => const OnboardingScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ الخلفية بيضاء
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ صورة اللوجو
            Image.asset(
              'assets/images/logo.png',
              width: 160.w,
              height: 160.h,
              // لو الصورة مش موجودة، يعرض أيقونة بديلة
              errorBuilder: (c, e, s) => Icon(Icons.favorite, size: 100.sp, color: const Color(0xFF005DA3)),
            ),
            
            SizedBox(height: 20.h),
            
            // ✅ اسم التطبيق
            Text(
              "Nabd App",
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF005DA3), // 🔵 الأزرق
              ),
            ),
          ],
        ),
      ),
    );
  }
}