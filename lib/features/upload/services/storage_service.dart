import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

// نوع الرفع (نفس الـ Enum المستخدم في الشاشة)
enum UploadType { image, video, audio, document }

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🚀 الدالة الرئيسية للرفع
  Future<String> uploadFile({
    required File file,
    required String patientId,
    required String category,
    required UploadType type,
    required Function(double) onProgress, // كول باك لتحديث الشريط
  }) async {
    try {
      String fileName = path.basename(file.path);
      String uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      
      // 1. تحديد المسار الذكي
      String storagePath = 'patients/$patientId/medical_records/$category/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // 2. إعداد الرفع مع متابعة التقدم
      Reference ref = _storage.ref().child(storagePath);
      UploadTask task = ref.putFile(file, SettableMetadata(
        customMetadata: {
          'uploadedBy': uid,
          'category': category,
          'type': type.toString(),
        }
      ));

      // الاستماع للتقدم
      task.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred / event.totalBytes;
        onProgress(progress);
      });

      // انتظار الرفع
      await task;
      String downloadUrl = await ref.getDownloadURL();

      // 3. حفظ رابط الملف في Firestore (كسجل طبي جديد)
      await _saveToMedicalRecord(patientId, fileName, downloadUrl, category, type);

      return downloadUrl;
    } catch (e) {
      throw Exception("فشل الرفع: $e");
    }
  }

  // حفظ البيانات في كوليكشن السجلات الطبية
  Future<void> _saveToMedicalRecord(String patientId, String fileName, String url, String category, UploadType type) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    
    await _firestore.collection('medical_records').add({
      'patientId': patientId,
      'type': _mapUploadTypeToRecordType(type), // تحويل النوع
      'title': "مرفق جديد: $fileName",
      'doctorName': FirebaseAuth.instance.currentUser?.displayName ?? "مستخدم",
      'doctorId': uid,
      'date': FieldValue.serverTimestamp(),
      'summary': "تم رفع ملف جديد تحت تصنيف: $category",
      'details': {
        'fileUrl': url,
        'fileType': type.toString(),
        'category': category,
        'fileName': fileName,
      }
    });
  }

  // دالة مساعدة للتحويل بين أنواع الرفع وأنواع السجلات
  String _mapUploadTypeToRecordType(UploadType type) {
    switch (type) {
      case UploadType.image: return 'RecordType.lab'; // الصور غالباً تحاليل أو أشعة
      case UploadType.document: return 'RecordType.diagnosis'; // المستندات تقارير
      default: return 'RecordType.diagnosis';
    }
  }
}