import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AmbulanceScreen extends StatelessWidget {
  const AmbulanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("طلب إسعاف"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.shade50),
              child: Icon(Icons.emergency, size: 100.sp, color: Colors.red),
            ),
            SizedBox(height: 30.h),
            Text("هل تحتاج مساعدة عاجلة؟", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
            Text("سيتم إرسال أقرب وحدة إليك فوراً", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            SizedBox(height: 40.h),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text("اتصال بالطوارئ (123)", style: TextStyle(color: Colors.white, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}