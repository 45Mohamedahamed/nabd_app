import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IcuService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔐 الحصول على المعرف الحالي (مع التحقق من تسجيل الدخول)
  static String get _currentUid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("⚠️ لم يتم تسجيل الدخول! يرجى إعادة التشغيل.");
    return user.uid;
  }

  // ===========================================================================
  // 📡 1. جلب البيانات (Stream) - مع ميزات الفلترة والتحجيم
  // ===========================================================================
  static Stream<QuerySnapshot> getLogsStream({
    required String patientId,
    required bool isDoctor,
    String? filterType, // 💡 إبداع: فلترة حسب النوع (vital, medication, note)
    int limit = 50, // 💡 دقة: جلب آخر 50 سجل فقط لتسريع التطبيق
  }) {
    Query query = _db.collection('icu_logs');

    // 1. تصفية حسب المريض (أمان البيانات)
    if (isDoctor) {
      query = query.where('patientId', isEqualTo: patientId);
    } else {
      query = query.where('patientId', isEqualTo: _currentUid);
    }

    // 2. تصفية حسب نوع السجل (اختياري)
    if (filterType != null && filterType != 'all') {
      query = query.where('type', isEqualTo: filterType);
    }

    // 3. الترتيب والحد الأقصى (Performance Optimization)
    // ⚠️ ملاحظة: استخدام where مع orderBy يتطلب Composite Index في الفايربيز
    return query.orderBy('timestamp', descending: true).limit(limit).snapshots();
  }

  // ===========================================================================
  // ➕ 2. إضافة سجل جديد (Atomic Batch Write) - الأمان المطلق
  // ===========================================================================
  static Future<void> addLog(Map<String, dynamic> data) async {
    // نستخدم Batch لضمان أن العمليتين (إضافة السجل وتحديث الحالة) تتمان معاً أو تفشلان معاً
    WriteBatch batch = _db.batch();

    // أ. المراجع (References)
    DocumentReference newLogRef = _db.collection('icu_logs').doc(); // إنشاء ID تلقائي
    DocumentReference patientRef = _db.collection('users').doc(data['patientId']);

    // ب. تجهيز بيانات السجل
    batch.set(newLogRef, {
      ...data,
      'logId': newLogRef.id, // تخزين الـ ID داخل المستند لسهولة الاسترجاع
      'recordedBy': _currentUid,
      'timestamp': FieldValue.serverTimestamp(),
      'isAcknowledged': false, // 💡 فكرة: هل قام الطبيب بمراجعة هذا التنبيه؟
    });

    // ج. منطق تحديث حالة المريض (Business Logic)
    String status = data['status'] ?? 'Stable';
    Map<String, dynamic> userUpdates = {
      'healthStatus': status,
      'lastUpdate': FieldValue.serverTimestamp(),
      'needsUrgentAction': status == 'Critical',
    };

    // 💡 إضافة: إذا كانت الحالة حرجة، نسجل توقيت آخر إنذار ونزيد عداد التنبيهات
    if (status == 'Critical') {
      userUpdates['lastCriticalAlert'] = FieldValue.serverTimestamp();
      userUpdates['criticalCount'] = FieldValue.increment(1); // زيادة عداد الخطر
    }

    batch.update(patientRef, userUpdates);

    // د. تنفيذ "الدفعة" (Commit)
    await batch.commit();
  }

  // ===========================================================================
  // 🧪 3. جلب آخر علامات حيوية (Snapshot) - للعرض السريع
  // ===========================================================================
  static Future<Map<String, dynamic>?> getLastVitals(String patientId) async {
    try {
      final snapshot = await _db.collection('icu_logs')
          .where('patientId', isEqualTo: patientId)
          .where('type', isEqualTo: 'vital') // تأكد من جلب "العلامات الحيوية" فقط
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print("⚠️ Error fetching last vitals: $e");
      return null;
    }
  }

  // ===========================================================================
  // 📈 4. (إبداع جديد) جلب بيانات للرسم البياني (Trends)
  // ===========================================================================
  // هذه الدالة تجلب آخر 20 قراءة للضغط والنبض لرسم Chart
  static Future<List<Map<String, dynamic>>> getVitalTrends(String patientId) async {
    final snapshot = await _db.collection('icu_logs')
        .where('patientId', isEqualTo: patientId)
        .where('type', isEqualTo: 'vital')
        .orderBy('timestamp', descending: true)
        .limit(20) // آخر 20 قراءة فقط
        .get();

    // نعكس القائمة ليكون القديم أولاً (مناسب للرسم البياني من اليسار لليمين)
    return snapshot.docs.map((e) => e.data()).toList().reversed.toList();
  }

  // ===========================================================================
  // ✅ 5. (إبداع جديد) تأكيد استلام التنبيه (Acknowledge Alert)
  // ===========================================================================
  // يستخدمها الطبيب ليخبر النظام أنه "رأى" الحالة الحرجة، فيتوقف التنبيه
  static Future<void> acknowledgeAlert(String patientId, String logId) async {
    WriteBatch batch = _db.batch();

    // تحديث السجل نفسه أنه "تمت رؤيته"
    batch.update(_db.collection('icu_logs').doc(logId), {
      'isAcknowledged': true,
      'acknowledgedBy': _currentUid,
      'acknowledgedAt': FieldValue.serverTimestamp(),
    });

    // تحديث حالة المريض لإلغاء العلامة الحمراء
    batch.update(_db.collection('users').doc(patientId), {
      'needsUrgentAction': false, // إطفاء اللمبة الحمراء
    });

    await batch.commit();
  }
}