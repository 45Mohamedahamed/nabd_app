import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // ضروري لحل مشكلة Timestamp
import 'package:firebase_storage/firebase_storage.dart';
import '../model/radiology_model.dart'; // تأكد من صحة المسار

class RadiologyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // جلب الخدمات المتاحة
  Stream<List<RadiologyServiceModel>> getRadiologyServices() {
    return _db.collection('radiology_list').snapshots().map((snap) =>
        snap.docs.map((doc) => RadiologyServiceModel.fromMap(doc.data(), doc.id)).toList());
  }

  // حجز موعد
  Future<void> bookAppointment(String userId, RadiologyServiceModel service) async {
    await _db.collection('radiology_bookings').add({
      'userId': userId,
      'serviceId': service.id,
      'serviceTitle': service.title,
      'currentStep': 0,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
// 📝 تحديث تقرير الطبيب على أشعة معينة
  Future<void> updateDoctorReport(String resultId, String report) async {
    await _db.collection('radiology_results').doc(resultId).update({
      'doctorReport': report,
      'isReviewed': true, // تم التشخيص
      'reviewDate': FieldValue.serverTimestamp(),
    });
  }
  
  // ✅ تعديل جلب النتائج
  Stream<List<RadiologyResultModel>> getBabyRadiologyResults(String babyId) {
    return _db
        .collection('radiology_results')
        .where('babyId', isEqualTo: babyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RadiologyResultModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
  // جلب النتائج لل
  // دالة الرف
  Future<void> uploadXRay({
    required String babyId,
    required File imageFile,
    required String type,
  }) async {
    String fileName = 'xrays/$babyId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = _storage.ref().child(fileName);
    await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
    String downloadUrl = await ref.getDownloadURL();

    await _db.collection('radiology_results').add({
      'babyId': babyId,
      'imageUrl': downloadUrl,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'completed',
      'doctorReport': '',
    });
  }
}