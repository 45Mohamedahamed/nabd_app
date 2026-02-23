import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../incubators/model/IncubatorModel.dart';
import '../../incubators/Service/IncubatorService.dart';

class IncubatorDashboard extends StatefulWidget {
  final String incubatorId;
  const IncubatorDashboard({super.key, required this.incubatorId});

  @override
  State<IncubatorDashboard> createState() => _IncubatorDashboardState();
}

class _IncubatorDashboardState extends State<IncubatorDashboard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<IncubatorModel>(
      stream: IncubatorService().getIncubatorById(widget.incubatorId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _buildErrorState();
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
          );
        }

        final baby = snapshot.data!;

        // 🚨 نظام التنبيه والبروتوكول الآلي عند الخطر
        if (baby.isCritical) {
          // 💊 تفعيل بروتوكول الصيدلية تلقائياً (ذكاء اصطناعي طبي)
          Future.microtask(() {
            IncubatorService().sendAutoMedicineOrder(baby);
          });

          return Flash(
            infinite: true,
            duration: const Duration(milliseconds: 800),
            child: Scaffold(
              backgroundColor: const Color(0xFF2C0101), // أحمر داكن للتحذير
              appBar: _buildAppBar(isCritical: true),
              bottomNavigationBar: _buildEmergencyDrugNotification(), // إشعار طلب الدواء
              body: _buildDashboardContent(baby, isCritical: true),
            ),
          );
        }

        // الحالة المستقرة الطبيعية
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: _buildAppBar(isCritical: false),
          body: _buildDashboardContent(baby, isCritical: false),
        );
      },
    );
  }

  // --------------------------------------------------------------------
  // الهيكل الداخلي للمحتوى (Charts + Vitals)
  // --------------------------------------------------------------------
  Widget _buildDashboardContent(IncubatorModel baby, {required bool isCritical}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          if (isCritical) _buildCriticalAlertBar(), 
          
          _buildBabyHeader(baby),
          SizedBox(height: 25.h),
          
          _buildLiveCameraSimulation(isCritical),
          SizedBox(height: 25.h),
          
          _buildECGChart(baby, isCritical: isCritical),
          SizedBox(height: 25.h),
          
          _buildVitalsGrid(baby),
          SizedBox(height: 35.h),
          
          _buildActionButtons(baby, isCritical),
        ],
      ),
    );
  }

  // 💊 إشعار الممرضة بطلب الدواء من الصيدلية
  Widget _buildEmergencyDrugNotification() {
    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(15.h),
        decoration: BoxDecoration(
          color: Colors.orangeAccent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Row(
          children: [
            const Icon(Icons.medication_liquid, color: Colors.white, size: 28),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "تم طلب بروتوكول أدوية الطوارئ من الصيدلية آلياً باسم الطفل.",
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // شريط تنبيه علوي يظهر فقط عند الخطر
  Widget _buildCriticalAlertBar() {
    return FadeInDown(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 10.w),
            const Text("حالة حرجة: يرجى التدخل فوراً", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // الرسم البياني (ECG Simulation)
  Widget _buildECGChart(IncubatorModel baby, {required bool isCritical}) {
    return Container(
      height: 180.h,
      padding: EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isCritical ? Colors.red : Colors.cyanAccent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: baby.heartRateHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: isCritical ? Colors.redAccent : Colors.cyanAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true, 
                color: (isCritical ? Colors.red : Colors.cyanAccent).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // شبكة العلامات الحيوية
  Widget _buildVitalsGrid(IncubatorModel baby) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15.w,
      mainAxisSpacing: 15.h,
      childAspectRatio: 1.1,
      children: [
        _buildVitalCard("الحرارة", "${baby.temperature}°C", Icons.thermostat, Colors.orange),
        _buildVitalCard("النبض", "${baby.heartRate} BPM", Icons.favorite, Colors.redAccent),
        _buildVitalCard("الأكسجين", "${baby.oxygenLevel}%", Icons.air, Colors.blueAccent),
        _buildVitalCard("الوزن", "${baby.weight}g", Icons.monitor_weight_outlined, Colors.greenAccent),
      ],
    );
  }

  Widget _buildVitalCard(String label, String value, IconData icon, Color color) {
    return Pulse(
      infinite: true,
      duration: const Duration(seconds: 4),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 10.h),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(color: Colors.white54, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCameraSimulation(bool isCritical) {
    return Container(
      height: 160.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isCritical ? Colors.red : Colors.white10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.videocam_off_rounded, color: Colors.white10, size: 50),
          Positioned(
            top: 15, left: 15,
            child: Row(
              children: [
                Pulse(infinite: true, child: const CircleAvatar(radius: 4, backgroundColor: Colors.red)),
                SizedBox(width: 8.w),
                const Text("LIVE STREAM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBabyHeader(IncubatorModel baby) {
    return FadeInLeft(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(baby.babyName ?? "اسم الطفل غير متوفر", style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900)),
              Text("معرف الوحدة: ${baby.id}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          _buildStatusIndicator(baby.isCritical),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isCritical) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: isCritical ? Colors.red : Colors.green),
      ),
      child: Text(
        isCritical ? "حالة حرجة" : "حالة مستقرة",
        style: TextStyle(color: isCritical ? Colors.red : Colors.green, fontSize: 11.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(IncubatorModel baby, bool isCritical) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mic, color: Colors.white),
            label: const Text("تحدث للطفل", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan[700],
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => IncubatorService().triggerEmergency(baby),
            icon: const Icon(Icons.emergency_share, color: Colors.white),
            label: const Text("طلب طبيب", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCritical ? Colors.red : Colors.orange[800],
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar({required bool isCritical}) {
    return AppBar(
      title: Text(isCritical ? "⚠️ إنذار طوارئ" : "مراقبة العلامات الحيوية", 
        style: TextStyle(color: isCritical ? Colors.white : Colors.cyanAccent, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: isCritical ? Colors.white : Colors.cyanAccent),
    );
  }

  Widget _buildErrorState() => const Scaffold(body: Center(child: Text("خطأ في الاتصال بالسيرفر", style: TextStyle(color: Colors.white))));
}