import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 👇 استدعاء الموديل والسيرفر
import 'package:nabd_app/core/models/unified_medical_model.dart';
import 'package:nabd_app/features/doctor_tools/services/medical_record_service.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب ID المريض الحالي
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("تاريخي الطبي",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // 📡 الاستماع لبيانات الفايربيز
      body: StreamBuilder(
        // 👈 سيبها فاضية كده، وDart هيفهمها لوحده من السطر اللي تحته!
        stream: MedicalRecordService().getRecordsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // هنا لازم نحدد النوع يدوياً عشان إحنا شلناه من فوق
          final records = snapshot.data as List<UnifiedMedicalRecord>?;

          if (records == null || records.isEmpty) {
            return Center(
                child: Text("لا يوجد تاريخ طبي مسجل",
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp)));
          }

          final surgeries =
              records.where((r) => r.type == RecordType.surgery).toList();
          final diagnoses =
              records.where((r) => r.type == RecordType.diagnosis).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 💡 (ميزة إضافية) قسم التنبيهات لو موجودة في الـ details
                // يمكنك تفعيلها لو كنت تحفظ "حساسية" في الفايربيز
                /*
                _buildSectionTitle("تنبيهات هامة"),
                _buildAlertCard("حساسية مفرطة", "البنسلين", Icons.warning_amber_rounded, Colors.red),
                SizedBox(height: 20.h),
                */

                // 1. الأمراض والتشخيصات السابقة
                if (diagnoses.isNotEmpty) ...[
                  _buildSectionTitle("الأمراض والتشخيصات"),
                  // ✅ تم إزالة .toList() لتعمل مع الـ Spread Operator بشكل صحيح
                  ...diagnoses.map((d) => _buildInfoCard(d.title, d.summary,
                      Icons.medical_information, Colors.blue)),
                  SizedBox(height: 20.h),
                ],

                // 2. العمليات الجراحية (تصميم Timeline)
                if (surgeries.isNotEmpty) ...[
                  _buildSectionTitle("العمليات الجراحية السابقة"),
                  // ✅ تم إزالة .toList()
                  ...surgeries.map((s) => _buildTimelineItem(
                      s.title, "${s.doctorName} • ${s.date.year}")),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Text(title,
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF005DA3))),
    );
  }

  // بطاقة التشخيص
  Widget _buildInfoCard(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: ListTile(
        leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: color)),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
        subtitle: Text(subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }

  // بطاقة العملية (Timeline)
  Widget _buildTimelineItem(String title, String date) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // خط التايم لاين
        Column(
          children: [
            Container(
                width: 14.w,
                height: 14.w,
                margin: EdgeInsets.only(top: 5.h),
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.redAccent.withOpacity(0.4),
                          blurRadius: 5)
                    ])),
            Container(width: 2.w, height: 60.h, color: Colors.grey.shade300),
          ],
        ),
        SizedBox(width: 15.w),
        // بيانات العملية
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 20.h),
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.02), blurRadius: 10)
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: Colors.black87)),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12.sp, color: Colors.grey),
                    SizedBox(width: 5.w),
                    Text(date,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12.sp)),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // بطاقة التنبيه (اختيارية)
  Widget _buildAlertCard(
      String title, String desc, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30.sp),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: color)),
                Text(desc,
                    style: TextStyle(
                        color: Colors.grey.shade700, fontSize: 13.sp)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
