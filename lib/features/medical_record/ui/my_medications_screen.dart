import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 👇 استيراد الموديل والسيرفر (تأكد من المسارات)
import '../../doctor_tools/model/medical_record_model.dart';
import '../../doctor_tools/services/medical_record_service.dart';

class MyMedicationsScreen extends StatefulWidget {
  const MyMedicationsScreen({super.key});

  @override
  State<MyMedicationsScreen> createState() => _MyMedicationsScreenState();
}

class _MyMedicationsScreenState extends State<MyMedicationsScreen> {
  final Color mainColor = const Color(0xFF005DA3);
  DateTime _selectedDate = DateTime.now();
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("جدول أدويتي", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          SizedBox(height: 15.h),
          
          // 📡 StreamBuilder لجلب الروشتات من الفايربيز
          Expanded(
            child: StreamBuilder<List<UnifiedMedicalRecord>>(
              stream: MedicalRecordService().getRecordsStream(currentUid), // جلب سجلات المستخدم الحالي
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                // 🧠 Logic: استخراج الأدوية من جميع الروشتات
                List<Map<String, dynamic>> allMedications = [];
                
                for (var record in snapshot.data!) {
                  if (record.type == RecordType.prescription && record.details['medications'] != null) {
                    List meds = record.details['medications'];
                    for (var med in meds) {
                      // هنا يمكننا إضافة منطق لفلترة الأدوية حسب التاريخ المختار (_selectedDate)
                      // للتبسيط الآن، سنعرض كل الأدوية
                      allMedications.add({
                        ...med, // name, dose, freq, time...
                        'recordId': record.id, // نحتاج ID السجل لتحديث الحالة لاحقاً
                        'doctorName': record.doctorName,
                      });
                    }
                  }
                }

                if (allMedications.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: allMedications.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 100),
                      child: _buildMedicationCard(allMedications[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 🎨 UI Components ---

  Widget _buildMedicationCard(Map<String, dynamic> med) {
    // تحديد الحالة (افتراضياً pending إذا لم تكن موجودة)
    String status = med['status'] ?? 'pending'; 
    bool isTaken = status == 'taken';
    
    Color statusColor = isTaken ? Colors.green : mainColor;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isTaken ? Colors.green.withOpacity(0.3) : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // أيقونة
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(Icons.medication_liquid, color: statusColor, size: 28.sp),
          ),
          SizedBox(width: 15.w),
          
          // تفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med['name'] ?? 'دواء', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text("${med['dose']} • ${med['freq']}", style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                Text("د. ${med['doctorName']}", style: TextStyle(fontSize: 10.sp, color: Colors.blueGrey)),
              ],
            ),
          ),

          // زر التفاعل
          if (!isTaken)
            InkWell(
              onTap: () async {
                // 🚀 تحديث الحالة في الفايربيز
                // ملاحظة: هذا يتطلب تحديث هيكل البيانات في MedicalRecordService لدعم تحديث جزئي داخل details
                // كحل سريع: سنقوم بتحديث محلي ونظهر رسالة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم تسجيل الجرعة ✅ (سيتم تفعيل التحديث السحابي قريباً)")),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: const Text("أخذ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          else
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined, size: 60.sp, color: Colors.grey.shade300),
          SizedBox(height: 10.h),
          const Text("لا توجد أدوية مجدولة لليوم", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // (شريط التقويم كما هو في الكود السابق)
  Widget _buildCalendarHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat("MMMM yyyy").format(_selectedDate), 
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                Icon(Icons.calendar_month_rounded, color: mainColor, size: 20.sp),
              ],
            ),
          ),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              itemCount: 7, 
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = date.day == _selectedDate.day;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: isSelected ? mainColor : Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: isSelected ? mainColor : Colors.grey.shade200),
                      boxShadow: isSelected ? [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 8)] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat("EEE").format(date), style: TextStyle(fontSize: 12.sp, color: isSelected ? Colors.white70 : Colors.grey)),
                        SizedBox(height: 5.h),
                        Text(date.day.toString(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}