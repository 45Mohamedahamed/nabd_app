import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/appointment_model.dart'; // تأكد أن المسار صحيح لموديلك
import 'package:animate_do/animate_do.dart'; // 👈 ده السطر الناقص
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  final Color mainColor = const Color(0xFF005DA3);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("جدول مواعيدي", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 1. التبويبات
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 10.h),
            child: TabBar(
              controller: _tabController,
              labelColor: mainColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: mainColor,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              tabs: const [
                Tab(text: "القادمة"),
                Tab(text: "المكتملة"),
                Tab(text: "الملغاة"),
              ],
            ),
          ),

          // 2. المحتوى المربوط بالفايربيز
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFirestoreList("upcoming"),  // القادمة
                _buildFirestoreList("completed"), // المكتملة
                _buildFirestoreList("canceled"),  // الملغاة
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 المحرك الرئيسي: جلب البيانات من الفايربيز
  Widget _buildFirestoreList(String statusFilter) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: uid) // هات مواعيد المستخدم الحالي بس
          .where('status', isEqualTo: statusFilter) // فلتر بالحالة
          .orderBy('appointmentDate', descending: false) // رتب حسب التاريخ
          .snapshots(),
      builder: (context, snapshot) {
        // 1. حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. حالة عدم وجود بيانات
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(statusFilter);
        }

        // 3. بناء القائمة
        return ListView.builder(
          padding: EdgeInsets.all(20.w),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String docId = snapshot.data!.docs[index].id;

            // تحويل بيانات الفايربيز إلى الموديل الخاص بك
            AppointmentModel appointment = AppointmentModel(
              id: docId,
              doctorName: data['doctorName'] ?? 'طبيب',
              specialty: data['specialty'] ?? 'عام',
              imageUrl: data['doctorImage'] ?? 'assets/images/doc1.png', // صورة افتراضية لو مفيش
              // دمج التاريخ والوقت للعرض (أو استخدام التاريخ المحفوظ)
              date: (data['appointmentDate'] as Timestamp).toDate(),
              status: _getStatusEnum(data['status']),
              isVideoCall: false, // ممكن تضيف الحقل ده في الفايربيز لاحقاً
            );

            return FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: _AppointmentCard(
                appointment: appointment,
                mainColor: mainColor,
                timeString: data['appointmentTime'], // نمرر وقت الموعد النصي (10:00 AM)
                onMainAction: () => _handleMainAction(appointment),
                onSecondaryAction: () => _handleSecondaryAction(appointment, docId),
              ),
            );
          },
        );
      },
    );
  }

  // تحويل النص من الفايربيز إلى Enum
  AppointmentStatus _getStatusEnum(String status) {
    switch (status) {
      case 'upcoming': return AppointmentStatus.upcoming;
      case 'completed': return AppointmentStatus.completed;
      case 'canceled': return AppointmentStatus.canceled;
      default: return AppointmentStatus.upcoming;
    }
  }

  // واجهة الحالة الفارغة
  Widget _buildEmptyState(String status) {
    String message = "";
    IconData icon = Icons.event_busy;

    if (status == 'upcoming') {
      message = "لا توجد مواعيد قادمة، استمتع بيومك! 🌟";
      icon = Icons.calendar_today;
    } else if (status == 'completed') {
      message = "سجلك نظيف، لم تزر أي طبيب مؤخراً";
      icon = Icons.history;
    } else {
      message = "لا توجد مواعيد ملغاة ✅";
      icon = Icons.cancel_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80.sp, color: Colors.grey.shade300),
          SizedBox(height: 15.h),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- Actions ---
  void _handleMainAction(AppointmentModel app) {
    // هنا ممكن تفتح شاشة التفاصيل أو إعادة الحجز
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("سيتم تفعيل هذه الميزة قريباً")));
  }

  void _handleSecondaryAction(AppointmentModel app, String docId) async {
    if (app.status == AppointmentStatus.upcoming) {
      // 🛑 منطق الإلغاء الحقيقي من الفايربيز
      await FirebaseFirestore.instance.collection('appointments').doc(docId).update({'status': 'canceled'});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إلغاء الموعد بنجاح ❌")));
    }
  }
}

// -----------------------------------------------------------
// 3️⃣ كارت الموعد (محدث ليعرض الوقت النصي)
// -----------------------------------------------------------
class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final Color mainColor;
  final String? timeString; // الوقت النصي (مثلاً 10:00 AM)
  final VoidCallback onMainAction;
  final VoidCallback onSecondaryAction;

  const _AppointmentCard({
    required this.appointment,
    required this.mainColor,
    this.timeString,
    required this.onMainAction,
    required this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        statusColor = mainColor;
        statusText = "مؤكد";
        break;
      case AppointmentStatus.completed:
        statusColor = Colors.green;
        statusText = "مكتمل";
        break;
      case AppointmentStatus.canceled:
        statusColor = Colors.red;
        statusText = "ملغي";
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.w, height: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.grey.shade200,
                  image: appointment.imageUrl.startsWith('http') 
                    ? DecorationImage(image: NetworkImage(appointment.imageUrl), fit: BoxFit.cover)
                    : null, // لو الصورة URL
                ),
                child: !appointment.imageUrl.startsWith('http') 
                  ? const Icon(Icons.person, color: Colors.grey) 
                  : null,
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.doctorName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text(appointment.specialty, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          
          // تفاصيل الوقت
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(10.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), SizedBox(width: 6.w), Text(DateFormat('yyyy/MM/dd').format(appointment.date), style: TextStyle(fontSize: 12.sp))]),
                // عرض الوقت المحجوز الفعلي (String) بدلاً من وقت الـ DateTime
                Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), SizedBox(width: 6.w), Text(timeString ?? DateFormat('hh:mm a').format(appointment.date), style: TextStyle(fontSize: 12.sp))]),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          // الأزرار
          if (appointment.status == AppointmentStatus.upcoming)
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: onSecondaryAction, style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.shade200)), child: const Text("إلغاء الحجز", style: TextStyle(color: Colors.red)))),
                SizedBox(width: 10.w),
                Expanded(child: ElevatedButton(onPressed: onMainAction, style: ElevatedButton.styleFrom(backgroundColor: mainColor), child: const Text("تعديل", style: TextStyle(color: Colors.white)))),
              ],
            )
        ],
      ),
    );
  }
}