import 'package:cloud_firestore/cloud_firestore.dart';

// 1. موديل المرض
class DiseaseModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String brief;
  final String overview;
  final List<String> symptoms;
  final List<String> riskFactors;
  final List<String> prevention;
  final List<String> treatments;
  final String sourceName;
  final DateTime lastUpdated;

  DiseaseModel({
    required this.id, required this.name, required this.category, required this.imageUrl,
    required this.brief, required this.overview, required this.symptoms, required this.riskFactors,
    required this.prevention, required this.treatments, required this.sourceName, required this.lastUpdated,
  });

  // 📥 جلب من الفايربيز
  factory DiseaseModel.fromMap(Map<String, dynamic> map, String docId) {
    return DiseaseModel(
      id: docId,
      name: map['name'] ?? '',
      category: map['category'] ?? 'عام',
      imageUrl: map['imageUrl'] ?? '',
      brief: map['brief'] ?? '',
      overview: map['overview'] ?? '',
      symptoms: List<String>.from(map['symptoms'] ?? []),
      riskFactors: List<String>.from(map['riskFactors'] ?? []),
      prevention: List<String>.from(map['prevention'] ?? []),
      treatments: List<String>.from(map['treatments'] ?? []),
      sourceName: map['sourceName'] ?? '',
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 📤 رفع للفايربيز
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'brief': brief,
      'overview': overview,
      'symptoms': symptoms,
      'riskFactors': riskFactors,
      'prevention': prevention,
      'treatments': treatments,
      'sourceName': sourceName,
      'lastUpdated': FieldValue.serverTimestamp(), // توقيت السيرفر الدقيق
    };
  }
}

// ---------------------------------------------------------
