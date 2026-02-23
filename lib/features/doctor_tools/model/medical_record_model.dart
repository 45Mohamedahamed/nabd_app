import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// أنواع السجلات الطبية
enum RecordType { surgery, lab, diagnosis, prescription, icu }

class UnifiedMedicalRecord {
  final String id;
  final String patientId;
  final RecordType type;
  final String title;
  final String doctorName;
  final String doctorId; // مهمة لمعرفة من كتب التقرير
  final DateTime date;
  final String summary;
  final Map<String, dynamic> details; // لتخزين تفاصيل مثل قائمة الأدوية

  UnifiedMedicalRecord({
    required this.id,
    required this.patientId,
    required this.type,
    required this.title,
    required this.doctorName,
    required this.doctorId,
    required this.date,
    required this.summary,
    required this.details,
  });

  // 🔴 1. التحويل من Firebase (Map) إلى Dart Object
  factory UnifiedMedicalRecord.fromMap(Map<String, dynamic> map, String docId) {
    return UnifiedMedicalRecord(
      id: docId,
      patientId: map['patientId'] ?? '',
      // تحويل النص المخزن إلى Enum
      type: RecordType.values.firstWhere(
          (e) => e.toString() == map['type'],
          orElse: () => RecordType.diagnosis),
      title: map['title'] ?? 'سجل طبي',
      doctorName: map['doctorName'] ?? 'غير معروف',
      doctorId: map['doctorId'] ?? '',
      // تحويل Timestamp الخاص بفايربيز إلى DateTime
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      summary: map['summary'] ?? '',
      details: map['details'] ?? {},
    );
  }

  // 🟢 2. التحويل من Dart Object إلى Firebase (Map)
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'type': type.toString(), // نخزن الـ Enum كنص
      'title': title,
      'doctorName': doctorName,
      'doctorId': doctorId,
      'date': Timestamp.fromDate(date), // نخزن الوقت كـ Timestamp
      'summary': summary,
      'details': details,
    };
  }

  // 🎨 خصائص العرض (اللون والأيقونة)
  Color get color {
    switch (type) {
      case RecordType.surgery: return Colors.red;
      case RecordType.lab: return Colors.purple;
      case RecordType.diagnosis: return const Color(0xFF005DA3);
      case RecordType.prescription: return Colors.green;
      case RecordType.icu: return Colors.orange;
    }
  }

  IconData get icon {
    switch (type) {
      case RecordType.surgery: return Icons.local_hospital;
      case RecordType.lab: return Icons.science;
      case RecordType.diagnosis: return Icons.person_search;
      case RecordType.prescription: return Icons.medication;
      case RecordType.icu: return Icons.monitor_heart;
    }
  }
}