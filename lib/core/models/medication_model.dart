class MedicationModel {
  final String id;
  final String recordId; // ✅ هذا هو السطر الناقص المسبب للمشكلة
  final String name;
  final String type;
  final String time;
  final String status; // 'pending', 'taken', 'missed'
  final String dose;

  MedicationModel({
    required this.id,
    required this.recordId, // ✅ إضافته في الـ Constructor
    required this.name,
    required this.type,
    required this.time,
    required this.status,
    required this.dose,
  });

  MedicationModel copyWith({String? status}) {
    return MedicationModel(
      id: id,
      recordId: recordId, // ✅ لا تنس نسخه هنا أيضاً
      name: name,
      type: type,
      time: time,
      status: status ?? this.status,
      dose: dose,
    );
  }
}