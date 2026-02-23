import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/storage_service.dart'; // 👈 استدعاء الخدمة الجديدة

// موديل الملف المحلي (للعرض فقط)
class UploadedFileModel {
  final String id;
  final String name;
  final String size;
  final UploadType type;
  final File file; // الملف الفعلي
  double progress;
  bool isUploaded;
  bool isError; // حالة الخطأ

  UploadedFileModel({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.file,
    this.progress = 0.0,
    this.isUploaded = false,
    this.isError = false,
  });
}

class SmartUploadScreen extends StatefulWidget {
  final String patientId; // 👈 لازم نستلم الـ ID عشان نرفع له
  const SmartUploadScreen({super.key, required this.patientId});

  @override
  State<SmartUploadScreen> createState() => _SmartUploadScreenState();
}

class _SmartUploadScreenState extends State<SmartUploadScreen> {
  final Color mainColor = const Color(0xFF005DA3);
  final List<UploadedFileModel> _files = [];
  final List<String> _categories = ["تقرير طبي", "روشتة", "أشعة (X-Ray)", "تحاليل", "أخرى"];
  int _selectedCategory = 0;
  
  // حالة الرفع الكلي
  bool _isUploadingAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("مركز رفع المستندات", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. قسم التصنيف
                  Text("تصنيف المستند", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15.h),
                  SizedBox(
                    height: 50.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (c, i) => SizedBox(width: 10.w),
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedCategory == index;
                        return ChoiceChip(
                          label: Text(_categories[index]),
                          selected: isSelected,
                          onSelected: (v) => setState(() => _selectedCategory = index),
                          selectedColor: mainColor,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                          backgroundColor: Colors.white,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // 2. أزرار الإضافة (GridView)
                  Text("إضافة مرفقات", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15.h),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.w,
                    mainAxisSpacing: 15.h,
                    childAspectRatio: 1.5,
                    children: [
                      _buildActionCard(icon: Icons.camera_alt_rounded, label: "التقاط صورة", color: Colors.blue, onTap: () => _pickRealFile(UploadType.image)),
                      _buildActionCard(icon: Icons.videocam_rounded, label: "تسجيل فيديو", color: Colors.orange, onTap: () => _pickRealFile(UploadType.video)),
                      _buildActionCard(icon: Icons.mic_rounded, label: "ملف صوتي", color: Colors.redAccent, onTap: () => _pickRealFile(UploadType.audio)),
                      _buildActionCard(icon: Icons.attach_file_rounded, label: "ملف (PDF/Doc)", color: Colors.green, onTap: () => _pickRealFile(UploadType.document)),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  // 3. قائمة الملفات المختارة
                  if (_files.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("الملفات المرفقة (${_files.length})", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: _isUploadingAll ? null : () => setState(() => _files.clear()),
                          child: const Text("حذف الكل", style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _files.length,
                      itemBuilder: (context, index) => _buildFileItem(_files[index]),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 4. زر الرفع النهائي
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
            child: SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: (_files.isEmpty || _isUploadingAll) ? null : _uploadAllFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                ),
                child: _isUploadingAll 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                        SizedBox(width: 10.w),
                        const Text("رفع الملفات الآن", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // ⚙️ اختيار الملفات (Picker)
  // ---------------------------------------------------------
  Future<void> _pickRealFile(UploadType type) async {
    File? pickedFile;
    String? name;
    String size = "0 KB";

    try {
      if (type == UploadType.image || type == UploadType.video) {
        final ImagePicker picker = ImagePicker();
        final XFile? media = type == UploadType.image 
            ? await picker.pickImage(source: ImageSource.camera, imageQuality: 80) // ضغط الصورة
            : await picker.pickVideo(source: ImageSource.camera);
        
        if (media != null) {
          pickedFile = File(media.path);
          name = media.name;
        }
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: type == UploadType.audio ? FileType.audio : FileType.custom,
          allowedExtensions: type == UploadType.document ? ['pdf', 'doc', 'docx'] : null,
        );
        if (result != null) {
          pickedFile = File(result.files.single.path!);
          name = result.files.single.name;
        }
      }

      if (pickedFile != null) {
        int bytes = await pickedFile.length();
        size = "${(bytes / 1024 / 1024).toStringAsFixed(2)} MB";

        setState(() {
          _files.add(UploadedFileModel(
            id: DateTime.now().toString(),
            name: name!,
            size: size,
            type: type,
            file: pickedFile!,
          ));
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  // ---------------------------------------------------------
  // 🚀 الرفع الحقيقي (Upload Logic)
  // ---------------------------------------------------------
  Future<void> _uploadAllFiles() async {
    setState(() => _isUploadingAll = true);

    for (var fileModel in _files) {
      if (fileModel.isUploaded) continue; // تخطي ما تم رفعه

      try {
        await StorageService().uploadFile(
          file: fileModel.file,
          patientId: widget.patientId,
          category: _categories[_selectedCategory],
          type: fileModel.type,
          onProgress: (progress) {
            setState(() => fileModel.progress = progress);
          },
        );
        setState(() => fileModel.isUploaded = true);
      } catch (e) {
        setState(() => fileModel.isError = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل رفع ${fileModel.name}")));
      }
    }

    setState(() => _isUploadingAll = false);
    
    // إذا تم رفع الكل بنجاح
    if (_files.every((f) => f.isUploaded)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ تم رفع جميع الملفات وحفظها في السجل الطبي")));
      Navigator.pop(context);
    }
  }

  // ... (Widgets: _buildActionCard & _buildFileItem same as before with minor tweaks)
  Widget _buildActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    // (نفس الكود السابق للزر)
    return InkWell(onTap: onTap, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 30), Text(label)])));
  }

  Widget _buildFileItem(UploadedFileModel file) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        children: [
          Icon(file.isError ? Icons.error : (file.isUploaded ? Icons.check_circle : Icons.file_present), color: file.isError ? Colors.red : (file.isUploaded ? Colors.green : mainColor)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (!file.isUploaded && !file.isError)
                  LinearProgressIndicator(value: file.progress, minHeight: 2),
              ],
            ),
          ),
          if (!file.isUploaded) IconButton(icon: Icon(Icons.close), onPressed: () => setState(() => _files.remove(file)))
        ],
      ),
    );
  }
}