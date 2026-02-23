import 'package:flutter/material.dart';

class IncubatorModel {
  final String id;
  final String name; // رقم الحضانة (A1, B2...)
  final String status; // 'occupied' (مشغول), 'free' (متاح), 'cleaning' (تعقيم), 'maintenance' (صيانة)
  final String? babyName;
  final double temperature;
  final int heartRate;
  final int oxygenLevel;
  final double weight;
  // تم تغيير المسمى ليتطابق مع الـ UI والـ Charts
  final List<double> heartRateHistory; 

  IncubatorModel({
    required this.id,
    required this.name,
    required this.status,
    this.babyName,
    this.temperature = 0.0,
    this.heartRate = 0,
    this.oxygenLevel = 0,
    this.weight = 0.0,
    this.heartRateHistory = const [],
  });

  // 🚨 منطق الإنذار الذكي (Critical Logic)
  bool get isCritical {
    // نبض القلب > 180 أو < 100 | الأكسجين < 90% | الحرارة > 38 أو < 35.5
    return heartRate > 180 ||
        heartRate < 100 ||
        oxygenLevel < 90 ||
        temperature > 38.0 ||
        temperature < 35.5;
  }

  // تحديد اللون بناءً على حالة الإشغال والخطر
  Color get statusColor {
    if (isCritical) return const Color(0xFFEF4444); // أحمر صارخ عند الخطر
    switch (status) {
      case 'occupied': return const Color(0xFFEF4444); // أحمر حيوي
      case 'free': return const Color(0xFF10B981);     // أخضر مريح
      case 'cleaning': return const Color(0xFF3B82F6);  // أزرق تعقيم
      case 'maintenance': return const Color(0xFFF59E0B); // برتقالي صيانة
      default: return Colors.grey;
    }
  }

  // تحويل البيانات من Firebase Cloud Firestore أو Realtime Database
  factory IncubatorModel.fromMap(Map<String, dynamic> map, String id) {
    return IncubatorModel(
      id: id,
      name: map['name'] ?? '',
      status: map['status'] ?? 'free',
      babyName: map['babyName'],
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      heartRate: map['heartRate'] ?? 0,
      oxygenLevel: map['oxygenLevel'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      // التأكد من جلب القائمة وتصفيتها بدقة للرسم البياني
      heartRateHistory: map['heartRateHistory'] != null
          ? List<double>.from(map['heartRateHistory'].map((item) => item.toDouble()))
          : [0.0, 0.0, 0.0, 0.0, 0.0],
    );
  }

  // تحويل الموديل لـ Map في حالة الإرسال للسيرفر
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'babyName': babyName,
      'temperature': temperature,
      'heartRate': heartRate,
      'oxygenLevel': oxygenLevel,
      'weight': weight,
      'heartRateHistory': heartRateHistory,
    };
  }
}