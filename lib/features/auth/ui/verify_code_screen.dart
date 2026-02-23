import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'create_new_password_screen.dart'; // 👇 الصفحة اللي بعدها

class VerifyCodeScreen extends StatefulWidget {
  final String email; // عشان نعرضله الإيميل اللي اتبعت عليه
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final Color mainColor = const Color(0xFF005DA3); // الأزرق

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              "تأكيد الكود",
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: mainColor),
            ),
            SizedBox(height: 10.h),
            Text(
              "أدخل الكود الذي أرسلناه إلى رقمك أو بريدك\n${widget.email}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            
            SizedBox(height: 40.h),

            // 🔢 مربعات الأرقام (OTP)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCodeBox(context),
                _buildCodeBox(context),
                _buildCodeBox(context),
                _buildCodeBox(context),
              ],
            ),

            SizedBox(height: 40.h),

            // زر التحقق
           // ... نفس الكود بتاعك بس تأكد من زر التأكيد ...

            // زر التحقق
             SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
               onPressed: () {
            // (اختياري) هنا ممكن تتحقق إن الـ OTP طوله 4 أرقام
      
              // 👇 الانتقال لصفحة إنشاء كلمة مرور جديدة
                Navigator.pushReplacement( // استخدام Replacement عشان لما يرجع ميرجعش للكود تاني
                   context, 
                  MaterialPageRoute(builder: (c) => const CreateNewPasswordScreen())
               );
                },
                  style: ElevatedButton.styleFrom(
                   backgroundColor: mainColor,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                   child: Text("تأكيد", style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () {
                // كود إعادة الإرسال
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إعادة الإرسال")));
              },
              child: Text("لم تستلم الكود؟ إعادة إرسال", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت مربع الرقم الواحد
  Widget _buildCodeBox(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: mainColor),
        decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
        onChanged: (value) {
          // حركة ذكية: لو كتب رقم ينقل للي بعده
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}