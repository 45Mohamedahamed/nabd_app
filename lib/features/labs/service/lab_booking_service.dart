import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/lab_test_model.dart';

class LabBookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🧪 التعديل هنا: غيرنا النوع من void لـ String عشان نرجع الـ ID
  Future<String> checkoutLabCart({
    required String userId,
    required List<LabTestModel> selectedTests,
    required bool isHomeVisit,
    String? prescriptionUrl,
    Map<String, String>? address,
  }) async {
    // 1. إنشاء Ref جديد عشان ناخد الـ ID بتاعه
    final bookingRef = _db.collection('lab_bookings').doc();
    
    double total = selectedTests.fold(0, (sum, item) => sum + item.price);
    if (isHomeVisit) total += 100;

    // 2. الحفظ في الفايربيز
    await bookingRef.set({
      'bookingId': bookingRef.id,
      'userId': userId,
      'tests': selectedTests.map((t) => {'id': t.id, 'title': t.title}).toList(),
      'totalAmount': total,
      'isHomeVisit': isHomeVisit,
      'prescriptionUrl': prescriptionUrl,
      'address': address,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3. 👈 أهم خطوة: إرجاع الـ ID عشان نستخدمه في التتبع
    return bookingRef.id;
  }
}