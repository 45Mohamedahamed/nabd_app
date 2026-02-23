import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart'; // المكتبة المسؤولة عن فتح الروابط

class RadiologyTrackingScreen extends StatelessWidget {
  final int currentStep; // الخطوة الحالية (0 إلى 4)
  final String? pdfUrl;  // رابط ملف التقرير من الفايربيز

  const RadiologyTrackingScreen({
    super.key, 
    required this.currentStep, 
    this.pdfUrl,
  });

  // 📄 دالة فتح وتحميل ملف الـ PDF بدقة عالية
  void _downloadPDF(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("عذراً، ملف التقرير غير متوفر حالياً ⚠️"))
      );
      return;
    }

    final Uri url = Uri.parse(urlString);
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("جاري فتح ملف التقرير... 📄"))
      );
      
      // الفتح باستخدام تطبيق خارجي لضمان أفضل تجربة عرض للمستخدم
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('تعذر فتح الرابط $urlString');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في فتح الملف: $e ❌"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تتبع الفحص الإشعاعي"), 
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(25.w),
        child: Column(
          children: [
            _buildStep(0, "تم تأكيد الحجز", "تم استلام طلبك وتخصيص موعد", Icons.event_available),
            _buildLine(0),
            _buildStep(1, "مرحلة التحضير", "يرجى اتباع تعليمات الصيام/الصبغة", Icons.info_outline),
            _buildLine(1),
            _buildStep(2, "داخل غرفة الأشعة", "جاري إجراء الفحص الآن", Icons.settings_remote),
            _buildLine(2),
            _buildStep(3, "كتابة التقرير الطبي", "الطبيب الاستشاري يراجع الصور", Icons.edit_note),
            _buildLine(3),
            _buildStep(4, "النتيجة جاهزة", "يمكنك الآن تحميل التقرير والأشعة", Icons.cloud_download),
            
            const Spacer(),

            // يظهر الزر فقط عندما تكتمل جميع الخطوات (الخطوة رقم 4)
            if (currentStep == 4)
              FadeInUp(
                child: SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadPDF(context, pdfUrl), // استدعاء دالة التحميل
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text(
                      "تحميل التقرير الطبي (PDF)", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                      elevation: 5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int stepIndex, String title, String sub, IconData icon) {
    bool isDone = currentStep >= stepIndex;
    bool isCurrent = currentStep == stepIndex;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isDone ? Colors.indigo : Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: isCurrent 
              ? [BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] 
              : [],
          ),
          child: Icon(icon, color: isDone ? Colors.white : Colors.grey, size: 24.sp),
        ),
        SizedBox(width: 20.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: isDone ? Colors.black : Colors.grey)),
            Text(sub, style: TextStyle(fontSize: 11.sp, color: isDone ? Colors.indigo : Colors.grey)),
          ],
        )
      ],
    );
  }

  Widget _buildLine(int stepIndex) {
    return Container(
      margin: EdgeInsets.only(left: 22.w), // تعديل المحاذاة لتناسب الدائرة
      height: 40.h,
      width: 2.w,
      color: currentStep > stepIndex ? Colors.indigo : Colors.grey[300],
    );
  }
}