import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FoodDrugCameraScreen extends StatefulWidget {
  const FoodDrugCameraScreen({super.key});

  @override
  State<FoodDrugCameraScreen> createState() => _FoodDrugCameraScreenState();
}

class _FoodDrugCameraScreenState extends State<FoodDrugCameraScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // خلفية الكاميرا (صورة مؤقتة)
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1546069901-ba9599a7e63c", 
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          
          // إطار الماسح
          Center(
            child: Container(
              width: 300.w,
              height: 300.w,
              decoration: BoxDecoration(
                border: Border.all(color: _isScanning ? Colors.green : Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isScanning)
                    const CircularProgressIndicator(color: Colors.green)
                  else
                    Icon(Icons.qr_code_scanner, color: Colors.white70, size: 50.sp),
                ],
              ),
            ),
          ),

          // التعليمات والزر
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "وجه الكاميرا نحو الدواء وطبق الطعام",
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt, color: Colors.black, size: 30.sp),
                  onPressed: () {
                    setState(() => _isScanning = true);
                    Timer(const Duration(seconds: 3), () {
                      if (!mounted) return;
                      setState(() => _isScanning = false);
                      _showWarningDialog();
                    });
                  },
                ),
              ],
            ),
          ),

          // زر الخروج
          Positioned(
            top: 50.h,
            right: 20.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 50.sp),
            SizedBox(height: 10.h),
            Text("تحليل التفاعل", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 15.h),
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10.r)),
              child: const Text(
                "تحذير: تم رصد 'ورقيات خضراء' مع دواء 'Warfarin'.\nفيتامين K قد يقلل فاعلية الدواء.",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
              child: const Text("فهمت، شكراً"),
            )
          ],
        ),
      ),
    );
  }
}