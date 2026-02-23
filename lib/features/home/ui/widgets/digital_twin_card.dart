// احفظه في widgets/digital_twin_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DigitalTwinCard extends StatelessWidget {
  const DigitalTwinCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        // تدرج لوني يوحي بالمستقبل والبيانات (أخضر فيروري x أزرق سماوي)
        gradient: const LinearGradient(
          colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: const Color(0xFF00B09B).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Stack(
        children: [
          // صورة خلفية تعبيرية (مجسم إنسان رقمي)
          Positioned(
            right: -40, bottom: -20,
            child: Opacity(
              opacity: 0.2,
              child: Icon(Icons.accessibility_new_rounded, size: 180.sp, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(5)),
                  child: Text("تقنية استباقية 🔮", style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                ),
                SizedBox(height: 10.h),
                Text("توأمك الرقمي الصحي", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 5.h),
                Text(
                  "شاهد تأثير نمط حياتك على صحتك المستقبلية بالذكاء الاصطناعي.",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp),
                  maxLines: 2,
                ),
                SizedBox(height: 10.h),
                LinearProgressIndicator(value: 0.85, backgroundColor: Colors.white24, color: Colors.white, minHeight: 6.h),
                SizedBox(height: 5.h),
                Text("صحة التوأم: 85% (ممتازة)", style: TextStyle(color: Colors.white, fontSize: 10.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}