import 'package:flutter/material.dart';

// أنواع الأحداث الطبية
enum RecordType { surgery, lab, diagnosis, prescription, icu }

class UnifiedMedicalRecord {
  final String id;
  final String patientId;
  final RecordType type; // نوع الحدث
  final String title;    // العنوان (مثلاً: عملية الزايدة، تحليل دم)
  final String doctorName; // اسم الدكتور المسؤول
  final DateTime date;   // التاريخ
  final String summary;  // ملخص سريع
  final Map<String, dynamic> details; // تفاصيل إضافية (النتيجة، التقرير، الأدوية)

  UnifiedMedicalRecord({
    required this.id,
    required this.patientId,
    required this.type,
    required this.title,
    required this.doctorName,
    required this.date,
    required this.summary,
    required this.details,
  });

  // Helper: لتحديد لون ونوع الأيقونة بناءً على النوع
  Color get color {
    switch (type) {
      case RecordType.surgery: return Colors.red;
      case RecordType.lab: return Colors.purple;
      case RecordType.diagnosis: return Colors.blue;
      case RecordType.prescription: return Colors.green;
      case RecordType.icu: return Colors.orange;
    }
  }

  IconData get icon {
    switch (type) {
      case RecordType.surgery: return Icons.local_hospital;
      case RecordType.lab: return Icons.biotech;
      case RecordType.diagnosis: return Icons.assignment_ind;
      case RecordType.prescription: return Icons.medication;
      case RecordType.icu: return Icons.monitor_heart;
    }
  }
}