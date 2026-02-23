import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
// 👈 مكتبة الباركود الضرورية

// 👇👇 تأكد من صحة المسارات لديك 👇👇
import '../../../../core/enums/health_status.dart';
import '../../../core/services/health_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Screens
import '../../ai_check/ui/health_checkup_screen.dart';
import '../../../features/appointmen/medical_services_screen.dart';
import '../../mental_health/ui/mental_health_screen.dart';
import '../../doctors/ui/doctors_list_screen.dart';
import '../../medical_record/ui/my_medications_screen.dart';
import 'notification_screen.dart';
import '../../doctor_tools/ui/patient_medical_record_screen.dart';
import '../../doctor_tools/ui/doctor_scanner_screen.dart';
import '../../icu/ui/icu_timeline_screen.dart';
import '../../../features/doctor_tools/ui/patient_medical_record_screen.dart';
import '../../chat/ui/chat_screen.dart';
import '../../../features/home/ui/widgets/bio_scan_card.dart';
import '../../../features/respiratory/ui/respiratory_analyzer_screen.dart';
import '../../../features/upload/ui/upload_documents_screen.dart';
import '../../food_drug/ui/food_drug_camera_screen.dart';
import '../../emergency/ui/emergency_screen.dart'; // 👈 تأكد من وجود ملف الطوارئ
import '../../../features/home/ui/widgets/ar_medicine_card.dart'; // 👈 تأكد من وجود ملف صيدلية AR
// 👇 استدعاء شاشة السجل الطبي
import '../../doctor_tools/ui/patient_medical_record_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // عشان نجيب الـ ID بتاع المريض
import '../../../features/Medical Encyclopedia/ui/medical_hub_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HealthStatus _currentHealthStatus = HealthStatus.unknown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HealthService().fetchHeartRateAndAnalyze();
    });
  }

  // ---------------------------------------------------------
  // 📸 دالة مسح كود المريض (هي دي اللي بتشغل الزرار)
  // ---------------------------------------------------------
  // دالة زرار الباركود
  void _scanPatientQR() {
    // بدل ما نستخدم المكتبة القديمة، هنفتح شاشة الماسح الحديثة بتاعتنا
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorScannerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // خلفية هادية جداً
      body: SafeArea(
        child: Column(
          children: [
            // ─── 1. الهيدر (تم التعديل هنا لإضافة الأزرار) ───
            _buildProfessionalHeader(context),

            // ─── 2. المحتوى (Scrollable) ───
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شريط البحث
                    _buildSearchBar(),
                    SizedBox(height: 20.h),

                    // 🔥 كارت الفحص الشامل (البانر الرئيسي)
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: _buildHeroCard(
                        title: "الفحص الذكي الشامل",
                        subtitle: "ارفع تحاليلك ودع الذكاء الاصطناعي يحللها لك",
                        icon: Icons.analytics_rounded,
                        color1: const Color(0xFF448AFF),
                        color2: const Color(0xFF2979FF),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => const HealthCheckupScreen())),
                      ),
                    ),

                    SizedBox(height: 25.h),

                    // عنوان القسم
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Text(
                        "أدوات الـ AI المتطورة",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Cairo', // لو مستخدم خط كايرو
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),

                    // 🚀 قائمة الأدوات
                    Column(
                      children: [
                        _buildProFeatureCard(
                          title: "الماسح الحيوي",
                          subtitle: "قس نبضك ونسبة الأكسجين بالكاميرا فقط",
                          icon: Icons.fingerprint,
                          color: Colors.redAccent,
                          delay: 200,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const BioScanScreen())),
                        ),
                        SizedBox(height: 12.h),
                        _buildProFeatureCard(
                          title: "محلل التنفس",
                          subtitle: "تحليل صحة الرئة عبر صوت السعال والتنفس",
                          icon: Icons.air,
                          color: Colors.teal,
                          delay: 300,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) =>
                                      const RespiratoryAnalyzerScreen())),
                        ),
                        SizedBox(height: 12.h),
                        _buildProFeatureCard(
                          title: "فاحص الطعام والدواء",
                          subtitle: "صور وجبتك لمعرفة تعارضها مع أدويتك",
                          icon: Icons.fastfood_rounded,
                          color: Colors.orange,
                          delay: 400,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) =>
                                      const FoodDrugCameraScreen())),
                        ),
                        SizedBox(height: 12.h),
                        _buildProFeatureCard(
                          title: "صيدلية AR الذكية",
                          subtitle: "تعرف على أي دواء بتوجيه الكاميرا عليه",
                          icon: Icons.view_in_ar_rounded,
                          color: Colors.purple,
                          delay: 500,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const ArMedicineScreen())),
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    // عنوان الخدمات
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("خدماتك الطبية",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        const MedicalServicesScreen())),
                            child: Text("عرض الكل",
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.blueAccent)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // 🏥 شبكة الخدمات
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 15.h,
                      childAspectRatio: 0.85,
                      children: [
                        _buildQuickServiceItem(
                            "الأطباء",
                            Icons.person_search,
                            Colors.blue,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        const DoctorsListScreen()))),
                        _buildQuickServiceItem(
                            "أدويتي",
                            Icons.medication,
                            Colors.green,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        const MyMedicationsScreen()))),
                        _buildQuickServiceItem(
                            "استشارة",
                            Icons.chat,
                            Colors.purpleAccent,
                            () => Navigator.push(
                                context,
                              MaterialPageRoute(
                       builder: (c) =>  const ChatScreen(
                              // 👇 التعديلات الجديدة:
                         receiverName: "د. آلي",      // كان اسمها doctorName
                             receiverImage: "assets/images/doctor1.png", // صورة افتراضية
                            chatId: "ai_bot_chat",       // معرف للدردشة
                           isOnline: true, //(لو مطلوبة)
                          ),
                            ))),
                        _buildQuickServiceItem(
                            "النفسية",
                            Icons.psychology,
                            Colors.indigo,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        const MentalHealthScreen()))),
                        _buildQuickServiceItem(
                            "حجز",
                            Icons.calendar_month,
                            Colors.orangeAccent,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                        const MedicalServicesScreen()))),
                        _buildQuickServiceItem(
                            "ICU",
                            Icons.monitor_heart,
                            Colors.red,
                            () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => const IcuTimelineScreen(
                                        patientId: '123')))),
                        _buildQuickServiceItem(
                            "رفع مستندات",
                            Icons.upload_file,
                            const Color(0xFF005DA3),
                            () => Navigator.push(context, MaterialPageRoute(builder: (c) => // شلنا كلمة const، وبعتنا الـ patientId
SmartUploadScreen(patientId: FirebaseAuth.instance.currentUser?.uid ?? '')))),
                        // ... داخل قائمة الـ children في GridView
                        _buildQuickServiceItem(
                          "سجلي الطبي",
                          Icons.history_edu_rounded,
                          const Color(0xFF673AB7),
                          () {
                            // 👇 حل مؤقت للتجربة: الانتقال لصفحة بيضاء للتأكد إن الزرار شغال
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // تأكد إنك بتنادي الاسم صح، ولو لسه فيه خطأ، جرب تحذف الـ import وتكتبه تاني
                                builder: (c) =>
                                    const PatientMedicalRecordScreen(
                                        patientId: "test_user"),
                              ),
                            );
                          },
                        ),
// ... باقي الكروت (الأطباء، الصيدلية، إلخ)
                        _buildQuickServiceItem(
                          "الموسوعة الطبية", // العنوان
                          Icons.menu_book_rounded, // الأيقونة (كتاب مفتوح)
                          const Color(0xFF009688), // لون مميز (Teal)
                          () {
                            // 👇 التوجيه لشاشة المركز الطبي (Medical Hub)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const MedicalHubScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    // درع الخصوصية
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield, color: Colors.green, size: 24.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              "بياناتك الطبية مشفرة ومحفوظة على جهازك فقط.",
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.green[800]),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 👇👇 الويدجت الاحترافية (Design System) 👇👇
  // ---------------------------------------------------------------------------

  // 1. الهيدر (المعدل بإضافة الطوارئ والباركود)
  Widget _buildProfessionalHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: const NetworkImage(
                'https://img.freepik.com/free-psd/3d-illustration-human-avatar-profile_23-2150671142.jpg'),
            backgroundColor: Colors.grey[200],
          ),
          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("صباح الخير،",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                Text("أحمد عبد العزيز",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),

          // --- الأزرار الجديدة ---

          // 1. زر الطوارئ (الأحمر) 🚨
          IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => const EmergencyScreen())),
            icon: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.emergency, size: 20.sp, color: Colors.red),
            ),
          ),

          // 2. زر مسح الباركود (الأزرق) 📷
          // 👇 هنا تم ربط الدالة بالزر عشان يشتغل 👇
          IconButton(
            onPressed: _scanPatientQR,
            icon: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.qr_code_scanner,
                  size: 20.sp, color: Colors.blue[800]),
            ),
          ),

          // 3. زر الإشعارات
          // في شريط التطبيق العلوي
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const NotificationScreen()),
            ),
            icon: Badge(
              // 🔮 مستقبلاً: اقرأ الرقم من NotificationRepository().notifications.value.length
              label: const Text("1"), // رقم وهمي مؤقتاً
              child: Icon(Icons.notifications_none_rounded,
                  size: 26.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // 2. البحث
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "ابحث عن دكتور، تخصص، أو دواء...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  // 3. الكارت الرئيسي (Hero)
  Widget _buildHeroCard(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color1,
      required Color color2,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
                color: color1.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded,
                            color: Colors.yellowAccent, size: 16.sp),
                        SizedBox(width: 5.w),
                        Text("AI Powered",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 5.h),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.sp,
                          height: 1.4)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 35.sp),
            ),
          ],
        ),
      ),
    );
  }

  // 4. كروت الأدوات الاحترافية
  Widget _buildProFeatureCard(
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required int delay,
      required VoidCallback onTap}) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(height: 4.h),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                            height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16.sp, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }

  // 5. كروت الخدمات الصغيرة
  Widget _buildQuickServiceItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 10.h),
            Text(title,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
