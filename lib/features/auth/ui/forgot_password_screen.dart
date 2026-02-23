import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'verify_code_screen.dart'; // 👇 لازم تستدعي الصفحة اللي بعدها

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final Color mainColor = const Color(0xFF005DA3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("استعادة كلمة المرور", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 10.h),
            Text("أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق.", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            
            SizedBox(height: 30.h),

            TextFormField(
              controller: _emailController, // ✅ ربطنا الكنترولر
              decoration: InputDecoration(
                labelText: "البريد الإلكتروني",
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال البريد الإلكتروني")));
                    return;
                  }
                  
                  // 👇 الانتقال لصفحة الكود وتمرير الإيميل
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (c) => VerifyCodeScreen(email: _emailController.text),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: const Text("إرسال", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}