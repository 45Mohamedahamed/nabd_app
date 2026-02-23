import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SurgeryModel {
  final String id;
  final String patientName;
  final String surgeryType;
  final String doctorName;
  final String anesthesiaType;
  final String roomNumber;
  final DateTime scheduledTime;
  final int estimatedDurationMinutes;
  String status; // pending, in_progress, recovery, completed
  int currentStep; // 0: تجهيز، 1: تخدير، 2: جراحة، 3: إفاقة، 4: تم الخروج
  final String description;
  final String recoveryAdvice;

  SurgeryModel({
    required this.id,
    required this.patientName,
    required this.surgeryType,
    required this.doctorName,
    required this.anesthesiaType,
    required this.roomNumber,
    required this.scheduledTime,
    required this.estimatedDurationMinutes,
    required this.status,
    this.currentStep = 0,
    required this.description,
    required this.recoveryAdvice,
  });

  // 1️⃣ تحويل البيانات القادمة من Firebase (Map) إلى كائن (Model)
  factory SurgeryModel.fromMap(Map<String, dynamic> map, String docId) {
    return SurgeryModel(
      id: docId,
      patientName: map['patientName'] ?? '',
      surgeryType: map['surgeryType'] ?? '',
      doctorName: map['doctorName'] ?? '',
      anesthesiaType: map['anesthesiaType'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      // التعامل مع Timestamp الخاص بـ Firebase
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      estimatedDurationMinutes: map['estimatedDurationMinutes'] ?? 0,
      status: map['status'] ?? 'pending',
      currentStep: map['currentStep'] ?? 0,
      description: map['description'] ?? '',
      recoveryAdvice: map['recoveryAdvice'] ?? '',
    );
  }

  // 2️⃣ تحويل الكائن (Model) إلى (Map) لإرساله إلى Firebase
  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'surgeryType': surgeryType,
      'doctorName': doctorName,
      'anesthesiaType': anesthesiaType,
      'roomNumber': roomNumber,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'status': status,
      'currentStep': currentStep,
      'description': description,
      'recoveryAdvice': recoveryAdvice,
    };
  }

  // 3️⃣ الألوان المتفاعلة حسب الحالة (للتصميم)
  Color get statusColor {
    switch (status) {
      case 'in_progress':
        return const Color(0xFFD32F2F); // أحمر حيوي للعمليات الجارية
      case 'recovery':
        return Colors.orange.shade700; // برتقالي لمرحلة الإفاقة
      case 'completed':
        return Colors.green.shade600; // أخضر للعمليات المنتهية
      default:
        return const Color(0xFF005DA3); // أزرق للمجدولة
    }
  }

  // 4️⃣ نص الحالة بالعربي (لسهولة العرض)
  String get statusText {
    switch (status) {
      case 'in_progress':
        return "جارية الآن 🔴";
      case 'recovery':
        return "في الإفاقة 🟠";
      case 'completed':
        return "تمت بنجاح ✅";
      default:
        return "مجدولة 📅";
    }
  }
}