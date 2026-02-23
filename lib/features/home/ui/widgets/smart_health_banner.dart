import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/health_status.dart'; // استدعاء ملف الحالات

class SmartHealthBanner extends StatefulWidget {
  final HealthStatus status; // الحالة الحالية
  final VoidCallback onTap;  // ماذا يحدث عند الضغط

  const SmartHealthBanner({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<SmartHealthBanner> createState() => _SmartHealthBannerState();
}

class _SmartHealthBannerState extends State<SmartHealthBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // أنيميشن النبض (عشان البانر يبقى حيوي)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نجيب الألوان والنصوص المناسبة للحالة
    final config = _getStatusConfig(widget.status);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: config['colors'],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: config['shadowColor'].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    config['title'],
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8.h),
                  // الوصف
                  Text(
                    config['subtitle'],
                    style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.9), height: 1.4),
                  ),
                  SizedBox(height: 15.h),
                  // الزر الصغير
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      config['buttonText'],
                      style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            // الأيقونة المتحركة
            ScaleTransition(
              scale: _controller,
              child: Icon(config['icon'], color: Colors.white.withOpacity(0.9), size: 60.sp),
            ),
          ],
        ),
      ),
    );
  }

  // الدالة اللي بتحدد الألوان والكلام حسب الحالة
  Map<String, dynamic> _getStatusConfig(HealthStatus status) {
    switch (status) {
      case HealthStatus.stable:
        return {
          'colors': [const Color(0xFF005DA3), const Color(0xFF0077CC)],
          'shadowColor': const Color(0xFF005DA3),
          'icon': Icons.check_circle_outline,
          'title': "صحتك ممتازة 👍",
          'subtitle': "المؤشرات الحيوية طبيعية، حافظ على هذا النمط.",
          'buttonText': "سجل المؤشرات",
        };
      case HealthStatus.warning:
        return {
          'colors': [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
          'shadowColor': const Color(0xFFFF9800),
          'icon': Icons.info_outline,
          'title': "انتبه لصحتك ⚠️",
          'subtitle': "هناك بعض الأعراض التي تحتاج لمتابعة، يفضل الراحة.",
          'buttonText': "فحص جديد",
        };
      case HealthStatus.critical:
        return {
          'colors': [const Color(0xFFD32F2F), const Color(0xFFEF5350)],
          'shadowColor': const Color(0xFFD32F2F),
          'icon': Icons.warning_amber_rounded,
          'title': "تنبيه صحي 🚨",
          'subtitle': "الأعراض تشير لحالة طارئة، يرجى استشارة طبيب فوراً.",
          'buttonText': "طلب إسعاف",
        };
      default: // الحالة المجهولة (unknown)
        return {
          'colors': [Colors.blueGrey, Colors.blueGrey.shade300],
          'shadowColor': Colors.blueGrey,
          'icon': Icons.favorite_border,
          'title': "كيف تشعر اليوم؟",
          'subtitle': "قم بإجراء الفحص الذكي للاطمئنان على صحتك.",
          'buttonText': "ابدأ الفحص الآن",
        };
    }
  }
}