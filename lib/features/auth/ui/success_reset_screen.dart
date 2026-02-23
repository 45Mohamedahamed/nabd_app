import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login_screen.dart'; // 👇 يرجع يسجل دخول بقى

class SuccessResetScreen extends StatelessWidget {
  const SuccessResetScreen({super.key});

  final Color mainColor = const Color(0xFF005DA3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // علامة الصح الكبيرة
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                color: mainColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, size: 80.sp, color: mainColor),
            ),
            
            SizedBox(height: 30.h),
            
            Text(
              "تم بنجاح!",
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10.h),
            Text(
              "تم تغيير كلمة المرور بنجاح، يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  // يمسح كل اللي فات ويرجع لصفحة الدخول
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (c) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text("الذهاب لتسجيل الدخول", style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}