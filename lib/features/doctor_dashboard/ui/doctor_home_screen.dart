import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

// 👇 ربط الشاشات ببعضها (تأكد من صحة المسارات)
import '../../icu/ui/icu_timeline_screen.dart'; 
import '../../doctor_tools/ui/doctor_scanner_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> with SingleTickerProviderStateMixin {
  // 🎨 الألوان
  final Color mainColor = const Color(0xFF005DA3);
  final Color criticalColor = const Color(0xFFD32F2F);
  final Color accentColor = const Color(0xFFF0F4F8);

  // 👤 بيانات الطبيب
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // 🔄 التحكم في التبويبات
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // 📡 كويري لجلب مواعيد اليوم فقط
  Stream<QuerySnapshot> get _todayAppointmentsStream {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: currentUser?.uid)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('date')
        .snapshots();
  }

  // 📡 كويري لجلب الحالات الحرجة في الـ ICU (الربط مع النظام السابق)
  Stream<QuerySnapshot> get _criticalPatientsStream {
    return FirebaseFirestore.instance
        .collection('users') // أو collection المرضى الخاص بك
        .where('needsUrgentAction', isEqualTo: true) // الفلتر الذكي اللي عملناه في IcuService
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 1. الهيدر الثابت
            _buildHeader(),
            
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          // 2. بطاقة الطوارئ (تظهر فقط لو فيه خطر)
                          _buildCriticalAlertSection(),
                          
                          // 3. الإحصائيات والماسح
                          _buildStatsAndScanner(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(_buildTabBar()),
                    pinned: true,
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(), // 📅 جدول اليوم
                    _buildIcuPatientsList(),  // 🛌 مرضى العناية
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🏗️ بناء الواجهة (UI Blocks) ---

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: mainColor.withOpacity(0.1),
            backgroundImage: currentUser?.photoURL != null ? NetworkImage(currentUser!.photoURL!) : null,
            child: currentUser?.photoURL == null ? Icon(Icons.person, color: mainColor, size: 30) : null,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greetingMessage(), style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                Text(currentUser?.displayName ?? "د. غير مسجل", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.notifications_outlined, size: 28.sp)),
              Positioned(right: 12, top: 12, child: CircleAvatar(radius: 4, backgroundColor: criticalColor)),
            ],
          )
        ],
      ),
    );
  }

  // 🔥 قسم الطوارئ (الذكاء الاصطناعي في العرض)
  Widget _buildCriticalAlertSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _criticalPatientsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SizedBox.shrink(); // اختفاء تام لو مفيش خطر

        int count = snapshot.data!.docs.length;
        return Pulse(
          infinite: true,
          child: Container(
            margin: EdgeInsets.only(bottom: 20.h),
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [criticalColor, Color(0xFFE57373)]),
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [BoxShadow(color: criticalColor.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30.sp),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("تنبيه طوارئ ICU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      Text("يوجد $count مرضى في حالة حرجة الآن!", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1), // الذهاب لتاب العناية
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: criticalColor, shape: StadiumBorder()),
                  child: Text("معاينة"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsAndScanner() {
    return Row(
      children: [
        // كروت الإحصائيات (يمكن ربطها بـ Counts حقيقية مستقبلاً)
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(child: _statCard("اليوم", "12", Icons.calendar_today, Colors.blue)),
              SizedBox(width: 10.w),
              Expanded(child: _statCard("انتظار", "5", Icons.hourglass_empty, Colors.orange)),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        // زر الماسح الضوئي الكبير
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DoctorScannerScreen())),
            child: Container(
              height: 100.h,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [BoxShadow(color: mainColor.withOpacity(0.3), blurRadius: 8)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 35.sp),
                  SizedBox(height: 5.h),
                  Text("Scan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: mainColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: mainColor,
      indicatorWeight: 3,
      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
      tabs: const [
        Tab(text: "مواعيد اليوم"),
        Tab(text: "مراقبة العناية"),
      ],
    );
  }

  // 📅 قائمة المواعيد
  Widget _buildAppointmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _todayAppointmentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _emptyState("لا توجد مواعيد اليوم", Icons.event_available);

        return ListView.builder(
          padding: EdgeInsets.all(20.w),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: Container(
                margin: EdgeInsets.only(bottom: 15.h),
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(10.r)),
                      child: Text(DateFormat('hh:mm a').format(date), style: TextStyle(fontWeight: FontWeight.bold, color: mainColor)),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['patientName'] ?? "مجهول", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                          Text(data['type'] ?? "كشف عام", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: Icon(Icons.videocam_outlined, color: mainColor)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🛌 قائمة مرضى العناية (الربط مع IcuTimelineScreen)
  Widget _buildIcuPatientsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('isInIcu', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        
        // فرز: الحالات الحرجة أولاً
        var docs = snapshot.data!.docs;
        docs.sort((a, b) {
           bool aCrit = a['healthStatus'] == 'Critical';
           bool bCrit = b['healthStatus'] == 'Critical';
           if (aCrit && !bCrit) return -1;
           if (!aCrit && bCrit) return 1;
           return 0;
        });

        return ListView.builder(
          padding: EdgeInsets.all(20.w),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            bool isCritical = data['healthStatus'] == 'Critical';

            return GestureDetector(
              // 👇 هنا الربط مع شاشة الـ ICU اللي بنيناها
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => IcuTimelineScreen(patientId: docs[index].id, isDoctor: true))),
              child: Container(
                margin: EdgeInsets.only(bottom: 15.h),
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: isCritical ? criticalColor.withOpacity(0.5) : Colors.green.withOpacity(0.2)),
                  boxShadow: isCritical ? [BoxShadow(color: criticalColor.withOpacity(0.1), blurRadius: 10)] : [],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isCritical ? criticalColor.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      child: Icon(Icons.local_hospital, color: isCritical ? criticalColor : Colors.green),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['name'] ?? "مريض", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: isCritical ? criticalColor : Colors.green)),
                              SizedBox(width: 5.w),
                              Text(isCritical ? "حالة حرجة - انتبه!" : "مستقر", style: TextStyle(color: isCritical ? criticalColor : Colors.green, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 🛠️ Helpers ---
  
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.r), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp)),
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
        ],
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60.sp, color: Colors.grey.shade300),
          SizedBox(height: 10.h),
          Text(msg, style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
        ],
      ),
    );
  }

  String _greetingMessage() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير،';
    if (hour < 17) return 'طاب مساؤك،';
    return 'مساء الخير،';
  }
}

// كلاس مساعد لتثبيت الهيدر عند السكرول (Sliver)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.grey.shade50, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}