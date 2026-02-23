import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../model/surgery_model.dart';
import '../service/surgery_service.dart'; // تأكد من وجود السيرفيس المعتمد

class SurgeriesScreen extends StatefulWidget {
  final bool isDoctor; 
  const SurgeriesScreen({super.key, this.isDoctor = true});

  @override
  State<SurgeriesScreen> createState() => _SurgeriesScreenState();
}

class _SurgeriesScreenState extends State<SurgeriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text("غرفة العمليات الذكية", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        centerTitle: true, 
        backgroundColor: Colors.white, 
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: const Color(0xFF005DA3),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "العمليات الحالية"), 
            Tab(text: "في الإفاقة"), 
            Tab(text: "المنتهية")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSurgeryStream(["in_progress", "pending"]),
          _buildSurgeryStream(["recovery"]),
          _buildSurgeryStream(["completed"]),
        ],
      ),
    );
  }

  // 1️⃣ باني الـ Stream الرئيسي لربط الواجهة بالسيرفيس لحظياً
  Widget _buildSurgeryStream(List<String> statuses) {
    return StreamBuilder<List<SurgeryModel>>(
      stream: SurgeryService().getSurgeriesByStatus(statuses),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF005DA3)));
        }
        
        final surgeries = snapshot.data ?? [];
        
        if (surgeries.isEmpty) return _buildEmptyState();

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: surgeries.length,
          itemBuilder: (context, index) => _buildModernSurgeryCard(surgeries[index], index),
        );
      },
    );
  }

  // 2️⃣ كارت تتبع العملية المطور (UI المدمج)
  Widget _buildModernSurgeryCard(SurgeryModel surgery, int index) {
    return FadeInDown(
      delay: Duration(milliseconds: 100 * index),
      child: GestureDetector(
        onTap: () => _showSurgeryDetails(context, surgery),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    _buildTimeColumn(surgery),
                    SizedBox(width: 15.w),
                    Expanded(child: _buildInfoColumn(surgery)),
                    if (surgery.status == 'in_progress') _buildLivePulse(),
                  ],
                ),
              ),
              // الـ Tracker التفاعلي للأهالي والطاقم
              _buildPhaseTracker(surgery.currentStep, surgery.statusColor),
              _buildFooter(surgery),
            ],
          ),
        ),
      ),
    );
  }

  // 3️⃣ تتبع مراحل العملية (Phase Tracker)
  Widget _buildPhaseTracker(int currentStep, Color activeColor) {
    List<String> phases = ["تجهيز", "تخدير", "جراحة", "إفاقة", "خروج"];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(phases.length, (i) {
          bool isPast = i <= currentStep;
          return Column(
            children: [
              Icon(isPast ? Icons.check_circle : Icons.radio_button_unchecked, 
                   color: isPast ? activeColor : Colors.grey.shade300, size: 18.sp),
              SizedBox(height: 4.h),
              Text(phases[i], style: TextStyle(fontSize: 10.sp, color: isPast ? Colors.black87 : Colors.grey, fontWeight: isPast ? FontWeight.bold : FontWeight.normal)),
            ],
          );
        }),
      ),
    );
  }

  // --- دوال بناء الواجهة المساعدة (Helper UI Widgets) ---

  Widget _buildLivePulse() {
    return Pulse(
      infinite: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8.r)),
        child: Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 10.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTimeColumn(SurgeryModel s) {
    return Column(
      children: [
        Text(DateFormat('hh:mm').format(s.scheduledTime), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        Text(DateFormat('a').format(s.scheduledTime), style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInfoColumn(SurgeryModel s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.surgeryType, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: 4.h),
        Text("المريض: ${s.patientName}", style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildFooter(SurgeryModel s) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: s.statusColor.withOpacity(0.05), borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(Icons.meeting_room, size: 14.sp, color: s.statusColor), SizedBox(width: 5.w), Text("غرفة: ${s.roomNumber}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))]),
          Text("د. ${s.doctorName}", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // 🔬 نافذة التفاصيل والتحكم (BottomSheet)
  void _showSurgeryDetails(BuildContext context, SurgeryModel surgery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 650.h,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(24.w),
                children: [
                  Text(surgery.surgeryType, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF005DA3))),
                  const Divider(height: 30),
                  _buildDetailRow(Icons.person, "المريض", surgery.patientName),
                  _buildDetailRow(Icons.timer, "المدة المقدرة", "${surgery.estimatedDurationMinutes} دقيقة"),
                  _buildDetailRow(Icons.medical_information, "تخدير", surgery.anesthesiaType),
                  _buildDetailRow(Icons.description, "التفاصيل", surgery.description),
                  
                  SizedBox(height: 20.h),
                  Text("📦 تعليمات التعافي", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15.r), border: Border.all(color: Colors.blue.shade100)),
                    child: Text(surgery.recoveryAdvice, style: TextStyle(fontSize: 13.sp, height: 1.5, color: Colors.blue.shade900)),
                  ),
                ],
              ),
            ),
            if (widget.isDoctor) _buildDoctorActionPanel(surgery),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorActionPanel(SurgeryModel s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // استدعاء دالة التحديث في السيرفس
                // SurgeryService().updateSurgeryStep(s.id, s.currentStep + 1);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: s.statusColor,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: const Text("تحديث المرحلة التالية", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 10.w),
          IconButton.filled(
            onPressed: () {
               // SurgeryService().triggerSurgeryEmergency(s.id, s.roomNumber);
            },
            icon: const Icon(Icons.emergency),
            style: IconButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey),
          SizedBox(width: 12.w),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bed_outlined, size: 80.sp, color: Colors.grey.shade300),
          SizedBox(height: 15.h),
          Text("لا توجد عمليات جراحية حالياً", 
            style: TextStyle(fontSize: 16.sp, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}