import 'package:cloud_firestore/cloud_firestore.dart';

class IcuLogModel {
  final String id;
  final String title;       // عنوان الحدث
  final String description; // التفاصيل
  final DateTime timestamp; // وقت الحدث
  final String type;        // vital, medication, alert, doctor_note
  final String nurseName;   // اسم الممرض
  final String patientId;   // 👈 (1) تم إضافة المتغير هنا

  IcuLogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.nurseName,
    required this.patientId, // 👈 (2) تم استخدام this.patientId
  });

  factory IcuLogModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return IcuLogModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] ?? 'info',
      nurseName: data['nurseName'] ?? 'ICU Staff',
      patientId: data['patientId'] ?? '', // 👈 (3) استقبال الـ ID من الداتابيز
    );
  }

  // إضافة دالة toMap عشان لو حبيت ترفع البيانات لفايربيز
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'type': type,
      'nurseName': nurseName,
      'patientId': patientId,
    };
  }
}