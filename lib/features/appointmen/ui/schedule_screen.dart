import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color mainColor = const Color(0xFF005DA3);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("مواعيدي", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: mainColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: mainColor,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          tabs: const [
            Tab(text: "قادمة"),
            Tab(text: "مكتملة"),
            Tab(text: "ملغاة"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList("upcoming"),
          _buildAppointmentList("completed"),
          _buildAppointmentList("canceled"),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    // بيانات وهمية
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: status == "upcoming" ? 2 : 1,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(status);
      },
    );
  }

  Widget _buildAppointmentCard(String status) {
    Color statusColor;
    String statusText;
    
    if (status == "upcoming") {
      statusColor = mainColor;
      statusText = "تأكيد";
    } else if (status == "completed") {
      statusColor = Colors.green;
      statusText = "تم";
    } else {
      statusColor = Colors.red;
      statusText = "ملغى";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
      ),
      child: Column(
        children: [
          // تفاصيل الدكتور
          Row(
            children: [
              Container(
                width: 60.w, height: 60.w,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Icons.person, color: Colors.grey, size: 30.sp),
              ),
              SizedBox(width: 15.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("د. سارة أحمد", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  Text("أخصائي جلدية", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 15.h),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 10.h),
          
          // الموعد والزرار
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
                  SizedBox(width: 5.w),
                  Text("الاثنين, 12 يونيو", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  SizedBox(width: 15.w),
                  Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                  SizedBox(width: 5.w),
                  Text("11:00 AM", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                ],
              ),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              )
            ],
          ),
          
          // أزرار إضافية لو الموعد قادم
          if (status == "upcoming") ...[
            SizedBox(height: 15.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                    child: const Text("إلغاء", style: TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: const Text("دخول الشات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}