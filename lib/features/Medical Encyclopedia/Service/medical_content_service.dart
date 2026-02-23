import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medical_models.dart';
import '../../Health & Wellness/model/wellness_model.dart'; // موديل التوعية
class MedicalContentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ======== 📚 قسم الأمراض (Encyclopedia) ========

  // 1. إضافة مرض
  Future<void> addDisease(DiseaseModel disease) async {
    await _db.collection('diseases').add(disease.toMap());
  }

  // 2. جلب الأمراض (Stream مباشر)
  Stream<List<DiseaseModel>> getDiseasesStream() {
    return _db.collection('diseases').orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DiseaseModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // ======== 🌱 قسم التوعية (Wellness: Tips & Articles) ========

  // 3. إضافة محتوى (مقال أو نصيحة)
  Future<void> addWellnessContent(WellnessItem item) async {
    await _db.collection('wellness_content').add(item.toMap());
  }

  // 4. جلب كل محتوى التوعية (لشاشة Awareness)
  Stream<List<WellnessItem>> getWellnessStream() {
    return _db.collection('wellness_content').orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => WellnessItem.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // 5. جلب أحدث 3 مقالات فقط (لشاشة MedicalHub)
  Stream<List<WellnessItem>> getFeaturedArticlesStream() {
    return _db.collection('wellness_content')
        .where('type', isEqualTo: ContentType.article.name) // مقالات فقط
        .orderBy('date', descending: true)
        .limit(3)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => WellnessItem.fromMap(doc.data(), doc.id)).toList();
    });
  }
}