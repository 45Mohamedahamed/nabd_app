import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 👇 استدعاء الموديلات والخدمات
import '../../../../core/models/medication_model.dart'; // UnifiedMedicalRecord
import '../../../../features/doctor_tools/services/medical_record_service.dart';
import '../../../core/models/unified_medical_model.dart'; // Service

// --- الحالات (States) ---
abstract class MedicationsState {}

class MedicationsInitial extends MedicationsState {}

class MedicationsLoading extends MedicationsState {}

class MedicationsUpdated extends MedicationsState {
  final List<MedicationModel> medications;
  final DateTime selectedDate;
  MedicationsUpdated(this.medications, this.selectedDate);
}

// --- الكيوبت (Cubit) ---
class MedicationsCubit extends Cubit<MedicationsState> {
  final MedicalRecordService _service = MedicalRecordService();
  StreamSubscription? _subscription;

  // نخزن كل الأدوية القادمة من الفايربيز هنا
  List<MedicationModel> _allCloudMedications = [];
  DateTime _currentDate = DateTime.now();

  MedicationsCubit() : super(MedicationsInitial()) {
    _initData();
  }

  // 1. بدء الاستماع للفايربيز
  void _initData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    emit(MedicationsLoading());

    // نستمع لتدفق البيانات من السيرفر
    _subscription = _service.getRecordsStream(uid).listen((records) {
      _allCloudMedications.clear();

      // 🧠 Logic: استخراج الأدوية من سجلات الروشتات
      for (var record in records) {
        if (record.type == RecordType.prescription &&
            record.details['medications'] != null) {
          List rawMeds = record.details['medications'];

          for (int i = 0; i < rawMeds.length; i++) {
            var item = rawMeds[i];
            // تحويل البيانات الخام إلى موديل الدواء
            _allCloudMedications.add(MedicationModel(
              id: "${record.id}_$i", // إنشاء ID فريد
              recordId: record.id,
              name: item['name'] ?? 'Unknown',
              type: item['dose'] ??
                  'Pill', // نستخدم الجرعة كنوع مؤقتاً أو نضيف Type
              time: item['time'] ?? '09:00 AM',
              status: item['status'] ?? 'pending',
              dose: item['dose'] ?? '1 Unit',
            ));
          }
        }
      }
      // بعد جلب البيانات، نطبق فلتر التاريخ الحالي
      selectDate(_currentDate);
    });
  }

  // 2. تغيير التاريخ والفلترة
  void selectDate(DateTime date) {
    _currentDate = date;

    // فلترة بسيطة: (في التطبيق الحقيقي نحتاج منطق التكرار والمدة)
    // هنا سنعرض كل الأدوية النشطة في اليوم المختار
    // للتبسيط: سنفترض أن كل الأدوية تظهر يومياً
    emit(MedicationsUpdated(List.from(_allCloudMedications), _currentDate));
  }

  // 3. أخذ الدواء (تحديث محلي + مفروض تحديث فايربيز)
  void takeMedication(String id) {
    final index = _allCloudMedications.indexWhere((m) => m.id == id);
    if (index != -1) {
      // 1. تحديث الحالة محلياً فوراً (عشان السرعة)
      _allCloudMedications[index] =
          _allCloudMedications[index].copyWith(status: 'taken');

      // 2. تحديث الواجهة
      emit(MedicationsUpdated(List.from(_allCloudMedications), _currentDate));

      // 3. (متقدم) هنا يجب إرسال التحديث للفايربيز
      // MedicalRecordService().updateMedicationStatus(...);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel(); // إغلاق البث عند الخروج لمنع تسريب الذاكرة
    return super.close();
  }
}
