import 'package:flutter/material.dart';
import '../../../../core/enums/health_status.dart';

class AiHealthService {
  // دالة تأخذ الإجابات وترجع النتيجة
  static Map<String, dynamic> analyze(Map<String, bool> answers) {
    
    // 1. لو فيه ألم صدر أو تنفس -> خطر
    if (answers['chest_pain'] == true || answers['breathing'] == true) {
      return {
        'status': HealthStatus.critical, // الحالة حمراء
        'message': 'الأعراض تشير لاحتمالية مشكلة قلبية أو تنفسية.',
        'action': 'ambulance'
      };
    }

    // 2. لو فيه سخونية أو دوخة -> تحذير
    if (answers['fever'] == true || answers['dizziness'] == true) {
      return {
        'status': HealthStatus.warning, // الحالة برتقالي
        'message': 'لديك أعراض تتطلب الراحة واستشارة طبيب باطنة.',
        'action': 'doctor'
      };
    }

    // 3. لو مفيش حاجة -> مستقر
    return {
      'status': HealthStatus.stable, // الحالة زرقاء
      'message': 'الحمد لله، لا توجد أعراض مقلقة.',
      'action': 'home'
    };
  }
}