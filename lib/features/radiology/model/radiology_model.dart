import 'package:cloud_firestore/cloud_firestore.dart';

// 🛑 الموديل اللي السيرفيس بيدور عليه للحجز والخدمات
class RadiologyServiceModel {
  final String id;
  final String title;
  final String category;
  final double price;
  final String preparation;
  final int currentStep;

  RadiologyServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.preparation,
    this.currentStep = 0,
  });

  factory RadiologyServiceModel.fromMap(Map<String, dynamic> map, String docId) {
    return RadiologyServiceModel(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      preparation: map['preparation'] ?? 'لا توجد تحضيرات خاصة',
      currentStep: map['currentStep'] ?? 0,
    );
  }
}

// 🛑 الموديل الخاص بنتائج وصور الأشعة للطفل
class RadiologyResultModel {
  final String id;
  final String babyId;
  final String imageUrl;
  final String type;
  final DateTime timestamp;
  final String doctorReport;

  RadiologyResultModel({
    required this.id,
    required this.babyId,
    required this.imageUrl,
    required this.type,
    required this.timestamp,
    this.doctorReport = "",
  });

  factory RadiologyResultModel.fromMap(Map<String, dynamic> map, String docId) {
    return RadiologyResultModel(
      id: docId,
      babyId: map['babyId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? '',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
      doctorReport: map['doctorReport'] ?? '',
    );
  }
}