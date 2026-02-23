import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/doctor_model.dart';

class ClinicService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. جلب قائمة الأطباء (ممكن نفلتر بالتخصص)
  Stream<List<DoctorModel>> getDoctors({String category = "الكل"}) {
    Query query = _db.collection('doctors');
    if (category != "الكل") {
      query = query.where('specialty', isEqualTo: category);
    }
    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }
// في ملف clinic_service.dart

Future<void> bookAppointment({
  required String userId,
  required DoctorModel doctor,
  required DateTime selectedDate,
  required String selectedTime,
  // 👇 البيانات الجديدة المطلوبة
  required String patientName,
  required String phone,
  required String notes,
}) async {
  await _db.collection('appointments').add({
    'userId': userId,
    'doctorId': doctor.id,
    'doctorName': doctor.name,
    'doctorImage': doctor.imageUrl,
    'specialty': doctor.specialty,
    'appointmentDate': Timestamp.fromDate(selectedDate),
    'appointmentTime': selectedTime,
    'price': doctor.price,
    // 👇 تخزين بيانات المريض
    'patientName': patientName,
    'phone': phone,
    'notes': notes,
    'status': 'upcoming',
    'createdAt': FieldValue.serverTimestamp(),
  });
 } // 2. حجز موعد جديد
}