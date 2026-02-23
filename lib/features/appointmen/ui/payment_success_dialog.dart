import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 👇 استدعاء شاشة الشات
import '../../chat/ui/chat_screen.dart';

class PaymentSuccessDialog extends StatelessWidget {
  // 1️⃣ إضافة متغير لاستقبال اسم الدكتور
  final String doctorName;

  const PaymentSuccessDialog({
    super.key, 
    required this.doctorName, // 👈 مطلوب عشان نمرره للشات
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // علامة الصح
            Container(
              padding: EdgeInsets.all(25.w),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F9F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Color(0xFF00A86B), size: 40),
            ),
            
            SizedBox(height: 25.h),
            
            Text(
              "Payment Success",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            
            SizedBox(height: 10.h),
            
            Text(
              "Your payment has been successful, you can have a consultation session with your trusted doctor",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600, height: 1.5),
            ),
            
            SizedBox(height: 30.h),
            
            // زر "Chat Doctor"
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  // 👇 2️⃣ التعديل هنا: تمرير اسم الدكتور لصفحة الشات
                 Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatScreen(
      // 👇 هنا بنبعت بيانات الدكتور اللي تم الحجز معاه
      receiverName: "د. أحمد", // المفروض تكون جاية من بيانات الحجز
      receiverImage: "assets/images/doctor2.png",
      chatId: "booking_${DateTime.now().millisecondsSinceEpoch}", // ID فريد للحجز
    ),
  ),
);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                ),
                child: Text("Chat Doctor", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}