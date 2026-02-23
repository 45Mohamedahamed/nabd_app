import 'package:cloud_firestore/cloud_firestore.dart';

class BloodUnitModel {
  final String id;
  final String type;
  final int quantity;
  final DateTime lastUpdate;

  BloodUnitModel({required this.id, required this.type, required this.quantity, required this.lastUpdate});

  factory BloodUnitModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return BloodUnitModel(
      id: doc.id,
      type: data['type'] ?? '',
      quantity: data['quantity'] ?? 0,
      lastUpdate: (data['lastUpdate'] as Timestamp).toDate(),
    );
  }

  // ميزة إبداعية: مصفوفة التوافق (مين يقدر ياخد من الفصيلة دي)
  List<String> get compatibleWith {
    switch (type) {
      case "O-": return ["الكل (Universal Donor)"];
      case "AB+": return ["AB+ فقط"];
      default: return ["يحددها الطبيب"];
    }
  }
}