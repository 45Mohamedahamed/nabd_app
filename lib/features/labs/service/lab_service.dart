import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/lab_test_model.dart';

class LabService {
  final CollectionReference _labColl = FirebaseFirestore.instance.collection('lab_tests');

  // جلب التحاليل حسب القسم
  Stream<List<LabTestModel>> getTestsByCategory(String category) {
    Query query = _labColl;
    if (category != "الكل") {
      query = _labColl.where('category', isEqualTo: category);
    }
    return query.snapshots().map((snap) => 
      snap.docs.map((doc) => LabTestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList()
    );
  }

  // ميزة الحجز الفعلي
  Future<void> bookTest(String userId, LabTestModel test, bool isHomeSample) async {
    await FirebaseFirestore.instance.collection('lab_bookings').add({
      'userId': userId,
      'testId': test.id,
      'testTitle': test.title,
      'isHomeSample': isHomeSample,
      'status': 'pending',
      'bookingDate': FieldValue.serverTimestamp(),
      'price': test.price + (isHomeSample ? 50 : 0), // إضافة مصاريف الانتقال لو منزلية
    });
  }
}