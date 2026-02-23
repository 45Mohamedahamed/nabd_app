import 'package:cloud_firestore/cloud_firestore.dart';

class IcuLogModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String nurseName;
  final String type; // 'vital', 'medication', 'note'
  final String status; // 'Stable', 'Critical', 'Info'
  final String title;
  final String description;
  final DateTime timestamp;
  
  // بيانات العلامات الحيوية (اختيارية لأنها قد لا تكون موجودة في الملاحظات)
  final int? heartRate;
  final int? oxygenLevel;
  final int? bpSystolic;
  final int? bpDiastolic;

  IcuLogModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.nurseName,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.timestamp,
    this.heartRate,
    this.oxygenLevel,
    this.bpSystolic,
    this.bpDiastolic,
  });

  // 🛠️ دالة التحويل من Firebase Map إلى كائن (Factory Constructor)
  factory IcuLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return IcuLogModel(
      id: docId,
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      nurseName: map['nurseName'] ?? 'ممرض مناوب',
      type: map['type'] ?? 'note',
      status: map['status'] ?? 'Stable',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // 🛡️ حماية التاريخ من الـ Null ومن اختلاف الأنواع
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      
      // تحويل الأرقام بأمان
      heartRate: map['heartRate'] is int ? map['heartRate'] : int.tryParse(map['heartRate']?.toString() ?? ''),
      oxygenLevel: map['oxygenLevel'] is int ? map['oxygenLevel'] : int.tryParse(map['oxygenLevel']?.toString() ?? ''),
      bpSystolic: map['bpSystolic'] is int ? map['bpSystolic'] : int.tryParse(map['bpSystolic']?.toString() ?? ''),
      bpDiastolic: map['bpDiastolic'] is int ? map['bpDiastolic'] : int.tryParse(map['bpDiastolic']?.toString() ?? ''),
    );
  }

  // 📤 دالة التحويل العكسي (لو احتجت ترفع داتا من المودل)
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'nurseName': nurseName,
      'type': type,
      'status': status,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'heartRate': heartRate,
      'oxygenLevel': oxygenLevel,
      'bpSystolic': bpSystolic,
      'bpDiastolic': bpDiastolic,
    };
  }
}