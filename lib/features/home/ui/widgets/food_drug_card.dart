import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

// 👇 تأكد من استدعاء شاشة الكاميرا اللي عملناها
import '../../../food_drug/ui/food_drug_camera_screen.dart';

class FoodDrugCard extends StatelessWidget {
  const FoodDrugCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInRight( // أنيميشن دخول من اليمين عكس اللي قبله
      duration: const Duration(milliseconds: 1400),
      child: GestureDetector(
        onTap: () {
          // 👇 الانتقال لشاشة فاحص الطعام والدواء
          Navigator.push(context, MaterialPageRoute(builder: (c) => const FoodDrugCameraScreen()));
        },
        child: Container(
          height: 120.h, // نفس ارتفاع الكروت السابقة للتناسق
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            // تدرج برتقالي ناري يوحي بالنشاط والتنبيه
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5722), Color(0xFFFFAB91)], 
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5722).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // زخرفة خلفية
              Positioned(
                left: -20,
                bottom: -20,
                child: Icon(Icons.fastfood_rounded, size: 100.sp, color: Colors.white.withOpacity(0.1)),
              ),
              
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    // الأيقونة المميزة
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), 
                        shape: BoxShape.circle
                      ),
                      child: Icon(Icons.no_meals_rounded, color: Colors.white, size: 30.sp),
                    ),
                    
                    SizedBox(width: 15.w),

                    // النصوص
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "كاشف التفاعل الغذائي", 
                            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "صور وجبتك ودواءك معاً لكشف التعارضات", 
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11.sp),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),

                    // أيقونة الكاميرا والعدسة
                    Icon(Icons.center_focus_strong_rounded, color: Colors.white.withOpacity(0.8), size: 40.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}