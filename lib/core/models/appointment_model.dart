// models/appointment_model.dart

enum AppointmentStatus { upcoming, completed, canceled }

class AppointmentModel {
  final String id;
  final String doctorName;
  final String specialty;
  final String imageUrl;
  final DateTime date;
  final AppointmentStatus status;
  final bool isVideoCall; // ميزة إضافية: هل الكشف فيديو أم عيادة؟

  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.imageUrl,
    required this.date,
    required this.status,
    this.isVideoCall = false,
  });

  // 👇 دالة سحرية لتحويل بيانات الفايربيز (JSON) إلى هذا الكلاس فوراً
  factory AppointmentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      doctorName: data['doctorName'] ?? '',
      specialty: data['specialty'] ?? '',
      imageUrl: data['imageUrl'] ?? 'assets/images/default_doc.png',
      date: DateTime.parse(data['date']), // الفايربيز يخزن الوقت كـ Timestamp
      status: AppointmentStatus.values.firstWhere((e) => e.toString() == 'AppointmentStatus.${data['status']}'),
      isVideoCall: data['isVideoCall'] ?? false,
    );
  }
}