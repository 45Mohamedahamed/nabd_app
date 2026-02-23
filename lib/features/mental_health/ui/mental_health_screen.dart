import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen> with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String _voiceResult = "اضغط على الميكروفون للتحدث...";
  
  // أنيميشن للموجات الصوتية
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // لون هادي ومريح للأعصاب
      appBar: AppBar(
        title: const Text("المحلل النفسي السياقي (IQ)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // 1️⃣ القسم الأول: الربط السياقي (Contextual Insight)
            // ------------------------------------------------
            FadeInDown(
              child: Text("تحليل السياق الحالي", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 15.h),
            
            // كارت التحليل الذكي (محاكاة لسيناريو الصداع + النبض)
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)], // ألوان بنفسجية مهدئة
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [BoxShadow(color: const Color(0xFF764BA2).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.yellowAccent),
                        SizedBox(width: 10.w),
                        Text("ملاحظة ذكية (AI Insight)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      "\"لاحظت أنك بحثت عن 'صداع نصفي' 3 مرات اليوم، وساعتك سجلت معدل نبض مرتفع (105 bpm).\"",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.5),
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.white, size: 20.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              "قد يكون السبب توتر وليس مرض عضوي. هل تريد تجربة تمرين تنفس؟",
                              style: TextStyle(color: Colors.white, fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF764BA2)),
                            child: const Text("بدء استرخاء 🧘‍♂️"),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
                            child: const Text("حجز مختص"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // ------------------------------------------------
            // 2️⃣ القسم الثاني: محلل نبرة الصوت (Vocal Biomarker)
            // ------------------------------------------------
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Text("تحليل النبرة الصوتية", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 15.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    "سجل رسالة قصيرة تصف حالتك، وسيقوم الذكاء الاصطناعي بتحليل نبرة صوتك لاكتشاف مؤشرات القلق.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                  ),
                  SizedBox(height: 30.h),

                  // زر التسجيل التفاعلي
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 100.w,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.redAccent : (_isAnalyzing ? Colors.orange : const Color(0xFF00B09B)),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.redAccent : const Color(0xFF00B09B)).withOpacity(0.4),
                            blurRadius: _isRecording ? 20 : 10,
                            spreadRadius: _isRecording ? 5 : 0,
                          )
                        ],
                      ),
                      child: Center(
                        child: _isAnalyzing 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 40.sp),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // حالة التسجيل والنتيجة
                  if (_isRecording)
                    FadeIn(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 3.w),
                                width: 5.w,
                                height: 20.h + (index * 5 * _waveController.value), // تأثير موجات الصوت
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  
                  SizedBox(height: 10.h),
                  Text(
                    _isAnalyzing ? "جاري تحليل الموجات الصوتية..." : _voiceResult,
                    style: TextStyle(
                      color: _isAnalyzing ? Colors.orange : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎙️ دالة محاكاة التسجيل والتحليل
  void _toggleRecording() {
    if (_isAnalyzing) return;

    if (_isRecording) {
      // إيقاف التسجيل وبدء التحليل
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });

      // محاكاة وقت المعالجة (Simulation)
      Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          _isAnalyzing = false;
          _voiceResult = "النتيجة: نبرة صوتك تظهر علامات 'إجهاد عالٍ'.\nننصحك بأخذ قسط من الراحة.";
        });
        _showAnalysisDialog();
      });

    } else {
      // بدء التسجيل
      setState(() {
        _isRecording = true;
        _voiceResult = "جاري الاستماع...";
      });
    }
  }

  // عرض النتيجة في نافذة منبثقة
  void _showAnalysisDialog() {
    showDialog(
      context: context,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.psychology_alt, size: 60.sp, color: Colors.orange),
              SizedBox(height: 15.h),
              Text("تحليل الذكاء الاصطناعي", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              const Text("تم رصد تذبذب في النبرة (Jitter) يدل على قلق خفيف.", textAlign: TextAlign.center),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B09B)),
                child: const Text("حسناً، شكراً"),
              )
            ],
          ),
        ),
      ),
    );
  }
}