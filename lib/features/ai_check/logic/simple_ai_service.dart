import 'package:flutter/material.dart';
import '../../../features/home/ui/home_screen.dart'; // عشان نجيب HealthStatus
import '../../../../core/enums/health_status.dart';
class SimpleAiService {
  // دالة تأخذ الإجابات وترجع النتيجة والتوصية
  static Map<String, dynamic> analyzeHealth(Map<String, bool> answers) {
    // 1. سيناريو الخطر (Critical)
    if (answers['chest_pain'] == true || answers['breathing_difficulty'] == true) {
      return {
        'status': HealthStatus.critical,
        'title': 'تنبيه صحي عاجل! 🚨',
        'message': 'الأعراض التي لديك قد تشير إلى مشكلة قلبية أو تنفسية حادة.',
        'recommendation': 'يرجى التوجه لأقرب طوارئ فوراً أو طلب إسعاف من التطبيق.',
        'color': Colors.red,
        'action': 'call_ambulance',
      };
    }

    // 2. سيناريو التحذير (Warning)
    if (answers['fever'] == true || answers['dizziness'] == true) {
      return {
        'status': HealthStatus.warning,
        'title': 'تحتاج إلى استشارة ⚠️',
        'message': 'لديك أعراض تتطلب الاهتمام وقد تكون بداية لعدوى.',
        'recommendation': 'ننصحك بحجز موعد مع طبيب باطنة وشرب السوائل.',
        'color': Colors.orange,
        'action': 'book_doctor',
      };
    }

    // 3. سيناريو الاستقرار (Stable)
    return {
      'status': HealthStatus.stable,
      'title': 'حالتك مطمئنة ✅',
      'message': 'لا توجد أعراض خطيرة ظاهرة.',
      'recommendation': 'حافظ على نمط حياتك الصحي، وتابع قياساتك بانتظام.',
      'color': Colors.green,
      'action': 'go_home',
    };
  }
}