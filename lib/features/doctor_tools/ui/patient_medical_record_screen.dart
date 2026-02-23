import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

// 👇 استيراد الموديل والسيرفر الجديدين (تأكد من صحة المسار في مشروعك)
import '../model/medical_record_model.dart';
import '../services/medical_record_service.dart';

class PatientMedicalRecordScreen extends StatelessWidget {
  final String patientId;

  const PatientMedicalRecordScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // لون خلفية هادئ ومريح للعين
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "السجل الطبي الشامل",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Text(
              "ملف رقم: $patientId",
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      
      // 📡 1. القلب النابض: StreamBuilder للربط مع الفايربيز
      body: StreamBuilder<List<UnifiedMedicalRecord>>(
        // استدعاء دالة الجلب من السيرفر
        stream: MedicalRecordService().getRecordsStream(patientId),
        
        builder: (context, snapshot) {
          // أ. حالة التحميل (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF005DA3)),
            );
          }

          // ب. حالة الخطأ (Error)
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text("حدث خطأ في جلب البيانات:\n${snapshot.error}", 
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            );
          }

          // ج. حالة البيانات الفارغة (Empty State)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // د. عرض البيانات (Success)
          final records = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 50.h),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: Duration(milliseconds: index * 100), // تتابع جميل في الظهور
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. تصميم الخط الزمني (Timeline)
                      _buildTimelineLine(record, index == records.length - 1),
                      
                      SizedBox(width: 15.w),
                      
                      // 3. كارت تفاصيل السجل
                      Expanded(child: _buildRecordCard(record)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- 🎨 مكونات الواجهة (Widgets) ---

  Widget _buildTimelineLine(UnifiedMedicalRecord record, bool isLast) {
    return Column(
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            color: record.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(color: record.color.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)
            ],
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2.w,
              color: Colors.grey.shade300,
              margin: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
      ],
    );
  }

  Widget _buildRecordCard(UnifiedMedicalRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(left: BorderSide(color: record.color, width: 4.w)), // الشريط الملون الجانبي
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الكارت: النوع والتاريخ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTypeBadge(record),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    DateFormat('dd MMM yyyy').format(record.date),
                    style: TextStyle(color: Colors.grey, fontSize: 11.sp, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // العنوان الرئيسي
          Text(
            record.title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          
          SizedBox(height: 6.h),
          
          // اسم الدكتور
          Row(
            children: [
              CircleAvatar(radius: 10.r, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 12.sp, color: Colors.grey)),
              SizedBox(width: 6.w),
              Text(
                record.doctorName,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          Divider(height: 24.h, thickness: 0.5),
          
          // ملخص الحالة
          Text(
            record.summary,
            style: TextStyle(fontSize: 13.sp, color: Colors.black54, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          // زر "عرض التفاصيل" (اختياري)
          if (record.details.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("عرض التفاصيل الكاملة >", 
                style: TextStyle(color: record.color, fontSize: 12.sp, fontWeight: FontWeight.bold)),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildTypeBadge(UnifiedMedicalRecord record) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: record.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(record.icon, size: 14.sp, color: record.color),
          SizedBox(width: 6.w),
          Text(
            _getArabicType(record.type),
            style: TextStyle(
              color: record.color,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _getArabicType(RecordType type) {
    switch (type) {
      case RecordType.surgery: return "جراحة";
      case RecordType.lab: return "تحاليل";
      case RecordType.diagnosis: return "تشخيص";
      case RecordType.prescription: return "روشتة";
      case RecordType.icu: return "عناية";
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(Icons.folder_off_outlined, size: 60.sp, color: Colors.grey[400]),
          ),
          SizedBox(height: 15.h),
          Text(
            "لا توجد سجلات طبية لهذا المريض",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 5.h),
          Text(
            "سيظهر التاريخ الطبي هنا بمجرد إضافته",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}