import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

class RespiratoryAnalyzerScreen extends StatefulWidget {
  const RespiratoryAnalyzerScreen({super.key});

  @override
  State<RespiratoryAnalyzerScreen> createState() => _RespiratoryAnalyzerScreenState();
}

class _RespiratoryAnalyzerScreenState extends State<RespiratoryAnalyzerScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String _resultText = "اضغط لبدء فحص التنفس...";
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("محلل الجهاز التنفسي AI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            FadeInDown(
              child: Image.network(
                "https://cdn-icons-png.flaticon.com/512/2860/2860787.png", // صورة رئة تعبيرية
                height: 150.h,
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              "تحليل الكحة والتنفس",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF009688)),
            ),
            SizedBox(height: 10.h),
            Text(
              "قم بالسعال (الكحة) 3 مرات بوضوح أمام الميكروفون للكشف عن المؤشرات الحيوية.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            const Spacer(),
            
            // زر التسجيل النابض
            GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(30.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.redAccent : const Color(0xFF009688),
                      boxShadow: [
                        if (_isRecording)
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 20 * _pulseController.value,
                            spreadRadius: 10 * _pulseController.value,
                          )
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic_rounded,
                      color: Colors.white,
                      size: 50.sp,
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 30.h),
            
            if (_isAnalyzing)
              Column(
                children: [
                  const CircularProgressIndicator(color: Color(0xFF009688)),
                  SizedBox(height: 10.h),
                  const Text("جاري تحليل الترددات الصوتية..."),
                ],
              )
            else
              FadeInUp(
                child: Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Text(
                    _resultText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _toggleRecording() {
    if (_isAnalyzing) return;

    if (_isRecording) {
      // إيقاف وبدء التحليل
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });
      
      // محاكاة الاتصال بالـ API
      Timer(const Duration(seconds: 4), () {
        if(!mounted) return;
        setState(() {
          _isAnalyzing = false;
          _resultText = "النتيجة: كحة جافة.\nلا توجد مؤشرات على التهاب رئوي. \nيُنصح بشرب سوائل دافئة.";
        });
      });
    } else {
      setState(() {
        _isRecording = true;
        _resultText = "جاري الاستماع... (سعل الآن)";
      });
    }
  }
}