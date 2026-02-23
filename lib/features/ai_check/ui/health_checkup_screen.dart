import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../logic/simple_ai_service.dart';
import 'checkup_result_screen.dart'; // لسه هنعملها تحت

class HealthCheckupScreen extends StatefulWidget {
  const HealthCheckupScreen({super.key});

  @override
  State<HealthCheckupScreen> createState() => _HealthCheckupScreenState();
}

class _HealthCheckupScreenState extends State<HealthCheckupScreen> {
  // تخزين الإجابات
  final Map<String, bool> _answers = {
    'chest_pain': false,
    'breathing_difficulty': false,
    'fever': false,
    'dizziness': false,
    'headache': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الفحص الذكي", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "بماذا تشعر الآن؟",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF005DA3)),
            ),
            SizedBox(height: 10.h),
            Text(
              "ساعدنا في فهم حالتك لتقديم التوصية الصحيحة.",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 20.h),

            // قائمة الأسئلة
            Expanded(
              child: ListView(
                children: [
                  _buildQuestionTile("هل تشعر بألم في الصدر؟", 'chest_pain'),
                  _buildQuestionTile("هل تجد صعوبة في التنفس؟", 'breathing_difficulty'),
                  _buildQuestionTile("هل درجة حرارتك مرتفعة (حمى)؟", 'fever'),
                  _buildQuestionTile("هل تشعر بدوار أو دوخة؟", 'dizziness'),
                  _buildQuestionTile("هل تعاني من صداع مستمر؟", 'headache'),
                ],
              ),
            ),

            // زر التحليل
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: _analyzeAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005DA3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                ),
                child: const Text("تحليل الأعراض", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت السؤال
  Widget _buildQuestionTile(String question, String key) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: _answers[key]! ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _answers[key]! ? Colors.blue : Colors.grey.shade200),
      ),
      child: CheckboxListTile(
        activeColor: const Color(0xFF005DA3),
        title: Text(question, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
        value: _answers[key],
        onChanged: (val) {
          setState(() {
            _answers[key] = val!;
          });
        },
      ),
    );
  }

  // دالة تنفيذ التحليل والانتقال للنتيجة
  void _analyzeAndNavigate() {
    // 1. استدعاء الـ AI (المحلي حالياً)
    final result = SimpleAiService.analyzeHealth(_answers);

    // 2. الذهاب لصفحة النتيجة
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (c) => CheckupResultScreen(resultData: result),
      ),
    );
  }
}