import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart'; // مكتبة لعمل Zoom احترافي
import '../model/radiology_model.dart';
import '../service/radiology_service.dart';

class RadiologyViewerScreen extends StatefulWidget {
  final RadiologyResultModel result;
  const RadiologyViewerScreen({super.key, required this.result});

  @override
  State<RadiologyViewerScreen> createState() => _RadiologyViewerScreenState();
}

class _RadiologyViewerScreenState extends State<RadiologyViewerScreen> {
  late TextEditingController _reportController;

  @override
  void initState() {
    _reportController = TextEditingController(text: widget.result.doctorReport);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // أسود لإبراز تفاصيل الأشعة
      appBar: AppBar(
        title: Text("فحص: ${widget.result.type}"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.cyanAccent),
            onPressed: _saveReport,
          )
        ],
      ),
      body: Column(
        children: [
          // 🖼️ جزء عرض الصورة مع خاصية الـ Zoom
          Expanded(
            flex: 2,
            child: ClipRRect(
              child: PhotoView(
                imageProvider: NetworkImage(widget.result.imageUrl),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
            ),
          ),
          
          // ✍️ جزء كتابة التقرير الطبي
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("تقرير الطبيب الاستشاري", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: TextField(
                      controller: _reportController,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: "اكتب التشخيص هنا...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveReport() async {
    if (_reportController.text.isNotEmpty) {
      await RadiologyService().updateDoctorReport(widget.result.id, _reportController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم حفظ التقرير الطبي بنجاح ✅"))
        );
        Navigator.pop(context);
      }
    }
  }
}