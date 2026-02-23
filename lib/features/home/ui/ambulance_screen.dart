import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AmbulanceScreen extends StatelessWidget {
  const AmbulanceScreen({super.key});
  final Color mainColor = const Color(0xFF005DA3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخريطة (الخلفية)
          // في الواقع العملي نستخدم GoogleMap() هنا
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/map_placeholder.png'), // ⚠️ ضع صورة خريطة هنا
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. الهيدر (Ambulance + Back)
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text("Ambulance", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 40.w), // لموازنة المساحة
              ],
            ),
          ),

          // 3. شريط البحث العائم
          Positioned(
            top: 110.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search location, ZIP code...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),

          // 4. الرادار والموقع (منتصف الشاشة)
          Center(
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: mainColor.withValues(alpha: 0.3), width: 1),
                color: mainColor.withValues(alpha: 0.05),
              ),
              child: Center(
                child: Icon(Icons.location_on, color: mainColor, size: 40.sp),
              ),
            ),
          ),

          // 5. البطاقة السفلية (Confirm Location)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(25.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Confirm your address", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 24.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          "2640 Cabin Creek Rd #102 Alexandria, Virginia(VA), 22314",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      ),
                      child: const Text("Confirm Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}