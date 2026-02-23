import 'package:cloud_firestore/cloud_firestore.dart'; // سيبها عشان لما نرجع الفايربيز

class IcuLogModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'alert', 'vital', 'medication'
  final String nurseName;
  final String patientId; // 👈 دي اللي كانت ناقصة ومسببة المشكلة
  final DateTime timestamp;

  IcuLogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.nurseName,
    required this.patientId, // 👈 ضفناها هنا كمان في البناء
    required this.timestamp,
  });

  // دالة التحويل من فايربيز (خليها احتياطي لبعدين)
  factory IcuLogModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IcuLogModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'info',
      nurseName: data['nurseName'] ?? '',
      patientId: data['patientId'] ?? '', // استقبال الـ ID
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // دالة التحويل لـ Map (للرفع)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'nurseName': nurseName,
      'patientId': patientId,
      'timestamp': timestamp,
    };
  }
}