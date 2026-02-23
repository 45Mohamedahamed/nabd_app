import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/IncubatorModel.dart';

class IncubatorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1️⃣ جلب جميع الحضانات (لشاشة العرض الرئيسية ولوحة التحكم)
  Stream<List<IncubatorModel>> getAllIncubatorsStream() {
    return _db.collection('incubators').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return IncubatorModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2️⃣ جلب بيانات حضانة واحدة (للـ Dashboard)
  Stream<IncubatorModel> getIncubatorById(String id) {
    return _db.collection('incubators').doc(id).snapshots().map((doc) {
      return IncubatorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  // 3️⃣ حجز حضانة (للممرضة)
  Future<void> bookIncubator(String id, String babyName, double weight) async {
    await _db.collection('incubators').doc(id).update({
      'status': 'occupied',
      'babyName': babyName,
      'weight': weight,
      'admissionDate': FieldValue.serverTimestamp(),
    });
  }

  // 4️⃣ إضافة حضانة جديدة لقاعدة البيانات
  Future<void> addNewIncubator(String name) async {
    await _db.collection('incubators').add({
      'name': name,
      'status': 'free',
      'babyName': null,
      'temperature': 36.5,
      'heartRate': 0,
      'oxygenLevel': 0,
      'weight': 0.0,
      'heartRateHistory': [0.0, 0.0, 0.0, 0.0, 0.0],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 5️⃣ تعديل الحساسات يدوياً (للطبيب أو المحاكاة)
  Future<void> updateSensorsManually(String id, double temp, int heart, int ox) async {
    await _db.collection('incubators').doc(id).update({
      'temperature': temp,
      'heartRate': heart,
      'oxygenLevel': ox,
      'lastManualUpdate': FieldValue.serverTimestamp(),
    });
  }

  // 6️⃣ إفراغ الحضانة وتحويلها للتعقيم
  Future<void> setForCleaning(String id) async {
    await _db.collection('incubators').doc(id).update({
      'status': 'cleaning',
      'babyName': null,
    });
  }

  // 7️⃣ إرسال إشعار طوارئ لقاعدة البيانات
  Future<void> triggerEmergency(IncubatorModel unit) async {
    await _db.collection('emergency_alerts').add({
      'unitId': unit.id,
      'unitName': unit.name,
      'babyName': unit.babyName,
      'reason': (unit.oxygenLevel < 90) ? "انخفاض أكسجين" : "اضطراب نبض",
      'vitals': {
        'hr': unit.heartRate,
        'spo2': unit.oxygenLevel,
        'temp': unit.temperature
      },
      'time': FieldValue.serverTimestamp(),
      'isResolved': false,
    });
  }

  // 8️⃣ 💊 طلب دواء تلقائي (الربط مع الصيدلية عند الطوارئ)
  Future<void> sendAutoMedicineOrder(IncubatorModel baby) async {
    try {
      final pharmacyRef = _db.collection('pharmacy_orders');
      await pharmacyRef.add({
        'babyId': baby.id,
        'babyName': baby.babyName ?? "طفل غير مسمى",
        'type': 'EMERGENCY_PROTOCOL',
        'status': 'urgent',
        'items': [
          {'name': 'أدرينالين (جرعة طوارئ)', 'qty': 1},
          {'name': 'محلول ملحي وداعم تنفس', 'qty': 1},
        ],
        'timestamp': FieldValue.serverTimestamp(),
        'roomNumber': 'وحدة الحضانات الذكية',
      });
      print("Emergency Medicine Order Sent ✅");
    } catch (e) {
      print("Error sending pharmacy order ❌: $e");
    }
  }
}