import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/surgery_model.dart';

class SurgeryService {
  // 1️⃣ مرجع قاعدة البيانات
  final CollectionReference _surgeryColl = 
      FirebaseFirestore.instance.collection('surgeries');

  // 2️⃣ جلب العمليات لحظياً (Stream)
  // دي اللي بتخلي الـ Tabs في الشاشة تتحدث لوحدها أول ما الحالة تتغير
  Stream<List<SurgeryModel>> getSurgeriesByStatus(List<String> statuses) {
    return _surgeryColl
        .where('status', whereIn: statuses)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SurgeryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3️⃣ تحديث مرحلة العملية (للجراح / الأدمن)
  // Step: 0(تجهيز), 1(تخدير), 2(جراحة), 3(إفاقة), 4(خروج)
  Future<void> updateSurgeryStep(String surgeryId, int newStep) async {
    String newStatus = 'in_progress';
    
    if (newStep == 3) newStatus = 'recovery';
    if (newStep == 4) newStatus = 'completed';

    await _surgeryColl.doc(surgeryId).update({
      'currentStep': newStep,
      'status': newStatus,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }

  // 4️⃣ إضافة عملية جراحية جديدة للمستشفى
  Future<void> addNewSurgery(SurgeryModel surgery) async {
    await _surgeryColl.add(surgery.toMap());
  }

  // 5️⃣ طلب مساعدة طارئة لغرفة العمليات (Emergency Trigger)
  Future<void> triggerSurgeryEmergency(String surgeryId, String roomNumber) async {
    await FirebaseFirestore.instance.collection('emergencies').add({
      'type': 'Surgery Help',
      'surgeryId': surgeryId,
      'room': roomNumber,
      'time': FieldValue.serverTimestamp(),
      'status': 'active',
    });
  }
}