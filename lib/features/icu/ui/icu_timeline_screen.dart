import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

// 👇 استدعاء الملفات الصحيحة (تأكد من المسارات)
import '../model/icu_model.dart';
import '../Service/IcuService.dart'; 
import 'add_icu_log_screen.dart';

class IcuTimelineScreen extends StatelessWidget {
  final String patientId;
  final bool isDoctor;

  const IcuTimelineScreen({
    super.key,
    required this.patientId,
    this.isDoctor = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: _buildAppBar(),
      floatingActionButton: isDoctor ? _buildFab(context) : null,
      body: Column(
        children: [
          // لوحة المراقبة تظهر للدكتور فقط
          if (isDoctor) _buildDoctorLiveMonitor(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // 📡 الاستدعاء الصحيح باستخدام Named Parameters
              stream: IcuService.getLogsStream(
                patientId: patientId, 
                isDoctor: isDoctor,
              ),
              builder: (context, snapshot) {
                // 1. حالة التحميل
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. حالة الخطأ
                if (snapshot.hasError) {
                  return Center(child: Text("⚠️ حدث خطأ: ${snapshot.error}"));
                }

                // 3. حالة البيانات الفارغة
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // 4. تحويل البيانات باستخدام المودل الذكي (IcuLogModel)
                final docs = snapshot.data!.docs;
                final List<IcuLogModel> logs = docs.map((doc) {
                  return IcuLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 80.h), // مساحة للزر العائم
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _buildTimelineItem(log, index == logs.length - 1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 🎨 بناء العناصر (Widgets) ---

  Widget _buildTimelineItem(IcuLogModel log, bool isLast) {
    // تحديد الألوان بناءً على النوع والحالة
    bool isCritical = log.status == 'Critical';
    Color themeColor;
    IconData icon;

    if (log.type == 'vital') {
      themeColor = isCritical ? const Color(0xFFD32F2F) : const Color(0xFF388E3C);
      icon = isCritical ? Icons.warning_amber_rounded : Icons.monitor_heart;
    } else if (log.type == 'medication') {
      themeColor = const Color(0xFF1976D2);
      icon = Icons.medication;
    } else {
      themeColor = const Color(0xFFF57C00);
      icon = Icons.sticky_note_2;
    }

    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      // تأخير بسيط لكل عنصر ليعطي تأثير تتابع جميل
      delay: Duration(milliseconds: 100), 
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عمود التوقيت والخط
            SizedBox(
              width: 50.w,
              child: Column(
                children: [
                  Text(
                    DateFormat('hh:mm').format(log.timestamp),
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  ),
                  Text(
                    DateFormat('a').format(log.timestamp),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    height: 14.h, width: 14.h,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 6)],
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
                ],
              ),
            ),
            
            SizedBox(width: 10.w),
            
            // محتوى الكارت
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: log.type == 'vital'
                    ? _buildVitalCard(log, themeColor, icon)
                    : _buildNoteCard(log, themeColor, icon),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🩸 كارت العلامات الحيوية (تصميم احترافي)
  Widget _buildVitalCard(IcuLogModel log, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          // رأس الكارت
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18.sp, color: color),
                    SizedBox(width: 8.w),
                    Text("فحص علامات حيوية", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: color)),
                  ],
                ),
                _buildNurseBadge(log.nurseName),
              ],
            ),
          ),
          
          // جسم الكارت (القيم)
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _vitalIndicator("Heart Rate", "${log.heartRate ?? '--'}", "BPM", Icons.favorite, Colors.red),
                Container(height: 30.h, width: 1, color: Colors.grey.shade200),
                _vitalIndicator("O2 Sat", "${log.oxygenLevel ?? '--'}", "%", Icons.air, Colors.blue),
                Container(height: 30.h, width: 1, color: Colors.grey.shade200),
                _vitalIndicator("BP", "${log.bpSystolic ?? '--'}/${log.bpDiastolic ?? '--'}", "mmHg", Icons.compress, Colors.purple),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 📝 كارت الملاحظات والأدوية
  Widget _buildNoteCard(IcuLogModel log, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(log.title.isNotEmpty ? log.title : (log.type == 'medication' ? "إعطاء دواء" : "ملاحظة"), 
                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: color)),
              _buildNurseBadge(log.nurseName),
            ],
          ),
          SizedBox(height: 10.h),
          Text(log.description, style: TextStyle(fontSize: 13.sp, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  // --- 🛠️ المساعدات ---

  Widget _buildNurseBadge(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6.r)),
      child: Row(
        children: [
          Icon(Icons.person, size: 12.sp, color: Colors.grey.shade600),
          SizedBox(width: 4.w),
          Text(name, style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _vitalIndicator(String label, String val, String unit, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: color.withOpacity(0.8)),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: Colors.black87, fontFamily: 'Cairo')),
              TextSpan(text: " $unit", style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(children: [
             Text(isDoctor ? "غرفة العناية" : "سجلي الطبي", style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold)),
             SizedBox(width: 6.w),
             Pulse(infinite: true, child: Container(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 8))))
           ]),
           Text("ملف رقم: ${patientId.substring(0,5)}", style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
        ],
      ),
      backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AddIcuLogScreen(patientId: patientId))),
      backgroundColor: const Color(0xFF005DA3),
      elevation: 4,
      label: const Text("تسجيل حالة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.add_task, color: Colors.white),
    );
  }

  Widget _buildDoctorLiveMonitor() {
    return FadeInDown(
      child: Container(
        margin: EdgeInsets.all(15.w),
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF005DA3), Color(0xFF007AD9)]),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statItem("الحالة", "مستقرة", Icons.check_circle_outline),
            Container(height: 30, width: 1, color: Colors.white24),
            _statItem("الغرفة", "ICU-04", Icons.meeting_room),
            Container(height: 30, width: 1, color: Colors.white24),
            _statItem("الممرض", "سارة", Icons.health_and_safety),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20.sp),
        SizedBox(height: 4.h),
        Text(val, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_heart_outlined, size: 80.sp, color: Colors.grey.shade300),
          SizedBox(height: 10.h),
          Text("لا توجد سجلات بعد", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text("ابدأ بتسجيل أول حالة للمريض", style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}