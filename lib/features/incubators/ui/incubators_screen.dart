import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../incubators/model/IncubatorModel.dart';
import '../../incubators/Service/IncubatorService.dart';
import 'incubator_dashboard.dart'; // تأكد من اسم الملف الصحيح عندك
import '../widgets/incubator_booking_sheet.dart';

class SmartIncubatorMain extends StatelessWidget {
  const SmartIncubatorMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("نظام إدارة الحضانات", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0,
      ),
      body: Column(
        children: [
          _buildOccupancyCounter(), // شريط إحصائي ذكي
          Expanded(child: _buildIncubatorGrid()),
        ],
      ),
    );
  }

  Widget _buildIncubatorGrid() {
    return StreamBuilder<List<IncubatorModel>>(
      stream: IncubatorService().getAllIncubatorsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final list = snapshot.data!;
        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 15.w, mainAxisSpacing: 15.h, childAspectRatio: 0.85,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) => _buildUnitCard(context, list[index]),
        );
      },
    );
  }

  Widget _buildUnitCard(BuildContext context, IncubatorModel unit) {
    return FadeInUp(
      child: InkWell(
        onTap: () => _handleTap(context, unit),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(25.r),
            border: Border.all(color: unit.statusColor.withOpacity(0.3), width: 2),
            boxShadow: [BoxShadow(color: unit.statusColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              _buildUnitHeader(unit),
              Expanded(child: _buildUnitBody(unit)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitHeader(IncubatorModel unit) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: unit.statusColor.withOpacity(0.1), borderRadius: BorderRadius.vertical(top: Radius.circular(23.r))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(unit.name, style: TextStyle(fontWeight: FontWeight.w900, color: unit.statusColor)),
          if (unit.status == 'occupied') Pulse(infinite: true, child: const Icon(Icons.favorite, color: Colors.red, size: 16)),
        ],
      ),
    );
  }

  Widget _buildUnitBody(IncubatorModel unit) {
    if (unit.status == 'occupied') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, color: Colors.blue[300], size: 35.sp),
          Text(unit.babyName!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _miniSign(Icons.favorite, "${unit.heartRate}", Colors.red),
              _miniSign(Icons.air, "${unit.oxygenLevel}%", Colors.blue),
            ],
          )
        ],
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(unit.status == 'free' ? Icons.add_circle_outline : Icons.cleaning_services_outlined, size: 40.sp, color: Colors.grey[300]),
          Text(unit.status == 'free' ? "متاحة للحجز" : "جاري التعقيم", style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
        ],
      ),
    );
  }

  Widget _miniSign(IconData icon, String val, Color col) => Row(children: [Icon(icon, size: 12.sp, color: col), Text(val, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold))]);

  Widget _buildOccupancyCounter() {
    return Container(
      margin: EdgeInsets.all(16.w), padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("نشط", "14", Colors.redAccent),
          _statItem("متاح", "06", Colors.greenAccent),
          _statItem("تعقيم", "02", Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, Color col) => Column(children: [Text(val, style: TextStyle(color: col, fontSize: 20.sp, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11))]);

  void _handleTap(BuildContext context, IncubatorModel unit) {
  if (unit.status == 'free') {
    // 1. لو الحضانة فاضية.. افتح شيت الحجز
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IncubatorBookingSheet(unit: unit),
    );
  } else if (unit.status == 'occupied') {
    // 2. لو مشغولة.. افتح الـ Dashboard لمراقبة العلامات الحيوية
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IncubatorDashboard(incubatorId: unit.id)),
    );
  } else if (unit.status == 'cleaning') {
    // 3. لو في حالة تعقيم.. أظهر رسالة تنبيه
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("الوحدة قيد التعقيم.. ستكون متاحة قريباً 🧹"), backgroundColor: Colors.blue),
    );
  }
}
}