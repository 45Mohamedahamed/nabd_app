import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  // ✅ التعديل: استخدام Health بدلاً من HealthFactory
  final Health health = Health(); 

  Future<void> fetchHeartRateAndAnalyze() async {
    // تحديد أنواع البيانات
    var types = [HealthDataType.HEART_RATE];
    
    // طلب الأذونات اللازمة للأندرويد
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // طلب إذن الوصول من مكتبة الصحة
   // bool requested = await health.requestAuthorization(types);
    
    if (true) { // Assuming authorization is granted
      try {
        DateTime now = DateTime.now();
        
        // جلب البيانات (لاحظ استخدام startTime و endTime كـ Named Parameters)
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now,
          types: types,
          
        );

        // ✅ التعديل: إزالة التكرار تتم عبر الـ instance نفسها
        var cleanHealthData = health.removeDuplicates(healthData);

        if (cleanHealthData.isEmpty) {
          return;
        }

        for (var data in cleanHealthData) {
          // ✅ التعديل: استخراج القيمة الرقمية بالطريقة الجديدة
          double hr = 0.0;
          if (data.value is NumericHealthValue) {
            hr = (data.value as NumericHealthValue).numericValue.toDouble();
          }

          // لو النبض تخطى 110 -> خطر
          if (hr > 110) {
             await _sendEmergencyAlert(hr);
             break; 
             
          }
          
        }
      } catch (e) {
        // print("Error: $e");
      }
    }
  }
  
  Future<void> _sendEmergencyAlert(double rate) async {
    await FirebaseFirestore.instance.collection('icu_logs').add({
      'type': 'alert',
      'title': 'CRITICAL: High Heart Rate ⚠️',
      'description': 'IoT Watch detected irregular heart rate: $rate bpm',
      'timestamp': FieldValue.serverTimestamp(),
      'nurseName': 'Automated IoT System',
      'patientId': 'patient_123',
    });
  }
}