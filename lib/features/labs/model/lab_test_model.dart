class LabTestModel {
  final String id;
  final String title;
  final String category;
  final double price;
  final String instructions;
  final String resultDuration; // 👈 المتغير اللي مسبب المشكلة
  final bool homeSampleAvailable;

  LabTestModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.instructions,
    this.resultDuration = "24 ساعة", // قيمة افتراضية
    this.homeSampleAvailable = true,
  });

  // تحويل البيانات من Map (Firebase) إلى Model
  factory LabTestModel.fromMap(Map<String, dynamic> map, String docId) {
    return LabTestModel(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      instructions: map['instructions'] ?? '',
      resultDuration: map['resultDuration'] ?? '24 ساعة', // التأكد من القراءة
      homeSampleAvailable: map['homeSampleAvailable'] ?? false,
    );
  }

  // تحويل الـ Model إلى Map لرفعه للفايربيز
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'price': price,
      'instructions': instructions,
      'resultDuration': resultDuration,
      'homeSampleAvailable': homeSampleAvailable,
    };
  }
}