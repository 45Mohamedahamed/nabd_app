import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medical_record_model.dart';

class MedicalRecordService {
  final CollectionReference _recordsRef =
      FirebaseFirestore.instance.collection('medical_records');

  // 📡 جلب سجلات مريض معين (Stream)
  Stream<List<UnifiedMedicalRecord>> getRecordsStream(String patientId) {
    return _recordsRef
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true) // الأحدث أولاً
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UnifiedMedicalRecord.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ➕ إضافة سجل جديد
  Future<void> addRecord(UnifiedMedicalRecord record) async {
    await _recordsRef.add(record.toMap());
  }
}