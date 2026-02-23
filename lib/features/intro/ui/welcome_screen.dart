import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 👇 استدعاء صفحات الدخول والتسجيل (مهم جداً تكون المسارات صح)
import '../../auth/ui/login_screen.dart';
import '../../auth/ui/RegisterScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 50.h),
        child: Column(
          children: [
            const Spacer(),
            
            // صورة أو لوجو ترحيبي
          // 👇 ده الكود الجديد مكان الـ Icon
Image.asset(
  'assets/images/logo.png', // 1. تأكد ان اسم الصورة وامتدادها صح
  height: 120.h,            // 2. الطول (كبره أو صغره براحتك)
  width: 120.w,             // 3. العرض
  fit: BoxFit.contain,      // 4. عشان الصورة تحافظ على أبعادها وماتتمطش
  
  // 👇 ده كود حماية: لو الصورة مش موجودة أو فيها مشكلة، هيعرض الأيقونة القديمة بدالها
  errorBuilder: (context, error, stackTrace) {
    return Icon(
      Icons.health_and_safety, 
      size: 100.sp, 
      color: const Color(0xFF005DA3)
    );
  },
),
            Text(
              "أهلاً بك في نبض",
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005DA3)),
            ),
            SizedBox(height: 10.h),
            Text(
              "طريقك لحياة صحية أفضل، ابدأ الآن!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
            
            const Spacer(),

            // زر تسجيل الدخول
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005DA3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  elevation: 5,
                ),
                child: Text("تسجيل الدخول", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            
            SizedBox(height: 15.h),

            // زر إنشاء حساب
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const RegisterScreen())
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF005DA3), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                ),
                child: Text("إنشاء حساب جديد", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005DA3))),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}