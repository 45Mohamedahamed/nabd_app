import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRequestModel {
  final String? id;           // معرف الوثيقة في الفايربيز
  final String userId;       // معرف المستخدم اللي طلب الاستغاثة
  final String patientName;  // اسم المريض
  final String phone;        // رقم الهاتف
  final String caseType;     // نوع الحالة (قلب، تنفس، نزيف...)
  final String severity;     // مستوى الخطورة (Critical, Urgent, Stable)
  final GeoPoint location;   // الإحداثيات الجغرافية (Lat, Long)
  final String notes;        // ملاحظات إضافية
  final String status;       // حالة الطلب (pending, responding, completed)
  final DateTime? timestamp; // وقت الطلب

  EmergencyRequestModel({
    this.id,
    required this.userId,
    required this.patientName,
    required this.phone,
    required this.caseType,
    required this.severity,
    required this.location,
    this.notes = "",
    this.status = "pending",
    this.timestamp,
  });

  // 1️⃣ تحويل الكائن إلى Map (للرفع إلى Firebase)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'patientName': patientName,
      'phone': phone,
      'caseType': caseType,
      'severity': severity,
      'location': location, // الفايربيز بيخزن الـ GeoPoint كنوع أصلي
      'notes': notes,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(), // الوقت الفعلي من السيرفر
    };
  }

  // 2️⃣ تحويل البيانات من Firebase إلى الكائن (للقراءة والعرض)
  factory EmergencyRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EmergencyRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      patientName: data['patientName'] ?? '',
      phone: data['phone'] ?? '',
      caseType: data['caseType'] ?? 'غير محدد',
      severity: data['severity'] ?? 'Stable',
      location: data['location'] as GeoPoint,
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'pending',
      // معالجة تحويل Timestamp الخاص بفايربيز إلى DateTime بتاع دارت
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate() 
          : null,
    );
  }
}