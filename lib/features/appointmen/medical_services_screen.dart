import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../features/upload/ui/upload_documents_screen.dart';
// 👇👇 استدعاءات شاشات الأقسام (تأكد من صحة المسارات في مشروعك) 👇👇
import '../../features/clinics/ui/clinics_screen.dart';
import '../../features/doctors/ui/doctors_list_screen.dart';
import '../../features/icu/ui/icu_timeline_screen.dart';
import '../../features/labs/ui/labs_screen.dart';
import '../../features/radiology/ui/radiology_screen.dart';
import '../../features/blood_bank/ui/blood_bank_screen.dart';
import '../../features/pharmacy/ui/pharmacy_screen.dart';
import '../../features/ambulance/ui/ambulance_screen.dart';
import '../../../core/ui/coming_soon_screen.dart'; // الشاشة المؤقتة
import '../../features/surgeries/ui/surgeries_screen.dart';
import '../../features/incubators/ui/incubators_screen.dart';
import '../respiratory/ui/respiratory_analyzer_screen.dart';
import '../radiology/ui/radiology_screen.dart';
import '../../features/radiology/ui/radiology_screen.dart';
import '../../features/doctors/ui/doctors_list_screen.dart';

class MedicalServicesScreen extends StatefulWidget {
  const MedicalServicesScreen({super.key});

  @override
  State<MedicalServicesScreen> createState() => _MedicalServicesScreenState();
}

class _MedicalServicesScreenState extends State<MedicalServicesScreen> {
  // محاكاة لقاعدة البيانات (Data Source)
  final List<Map<String, dynamic>> _allServices = [
    {
      "id": "1",
      "title": "العيادات",
      "icon": Icons.local_hospital,
      "color": 0xFF2196F3,
      "route": "clinics"
    },
    {
      "id": "2",
      "title": "أفضل الأطباء",
      "icon": Icons.person_search,
      "color": 0xFF009688,
      "route": "doctors"
    },
    {
      "id": "3",
      "title": "المختبر",
      "icon": Icons.biotech,
      "color": 0xFF9C27B0,
      "route": "labs"
    },
    {
      "id": "4",
      "title": "مراكز الأشعة",
      "icon": Icons.document_scanner_outlined,
      "color": 0xFFFF9800,
      "route": "radiology"
    },
    {
      "id": "5",
      "title": "العناية (ICU)",
      "icon": Icons.monitor_heart,
      "color": 0xFFF44336,
      "route": "icu"
    },
    {
      "id": "6",
      "title": "العمليات",
      "icon": Icons.medical_services,
      "color": 0xFF3F51B5,
      "route": "surgeries"
    },
    {
      "id": "7",
      "title": "حضانات",
      "icon": Icons.child_care,
      "color": 0xFFE91E63,
      "route": "incubators"
    },
    {
      "id": "8",
      "title": "بنك الدم",
      "icon": Icons.bloodtype,
      "color": 0xFFD32F2F,
      "route": "blood_bank"
    },
    {
      "id": "9",
      "title": "صيدلية",
      "icon": Icons.local_pharmacy,
      "color": 0xFF4CAF50,
      "route": "pharmacy"
    },
    {
      "id": "10",
      "title": "إسعاف",
      "icon": Icons.emergency,
      "color": 0xFFB71C1C,
      "route": "ambulance"
    },
  ];

  // قائمة للعرض (عشان البحث)
  List<Map<String, dynamic>> _filteredServices = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredServices = _allServices; // في البداية بنعرض كله
  }

  // دالة البحث الذكي
  void _filterServices(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _allServices;
      } else {
        _filteredServices = _allServices
            .where((service) => service['title'].toString().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // لون خلفية مودرن
      appBar: AppBar(
        title: FadeInDown(
            child: const Text("الخدمات الطبية",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            // 1. شريط البحث
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterServices,
                  decoration: InputDecoration(
                    hintText: "ابحث عن خدمة (عيادات، تحاليل...)",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                  ),
                ),
              ),
            ),

            SizedBox(height: 25.h),

            // 2. بانر العروض
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: SizedBox(
                height: 140.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPromoBanner(
                        "خصم 50%", "على التحاليل الشاملة", Colors.blue),
                    SizedBox(width: 15.w),
                    _buildPromoBanner(
                        "كشف مجاني", "للأطفال أقل من 5 سنوات", Colors.orange),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25.h),

            // 3. عنوان القسم
            FadeInLeft(
              delay: const Duration(milliseconds: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("جميع الأقسام",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  Text("${_filteredServices.length} خدمة",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                ],
              ),
            ),

            SizedBox(height: 15.h),

            // 4. الشبكة الذكية (Grid)
            _filteredServices.isEmpty
                ? Center(
                    child: Column(children: [
                    SizedBox(height: 50.h),
                    const Icon(Icons.search_off, size: 50, color: Colors.grey),
                    const Text("لا توجد نتائج")
                  ]))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 15.h,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: _buildServiceCard(
                            context, _filteredServices[index]),
                      );
                    },
                  ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // --- ودجت الكارت ---
  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    Color itemColor = Color(service['color']);

    return GestureDetector(
      onTap: () => _navigateToService(context, service['route']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 5,
                offset: const Offset(0, 2))
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: itemColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(service['icon'], color: itemColor, size: 28.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              service['title'],
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // --- ودجت البانر ---
  Widget _buildPromoBanner(String title, String subtitle, Color color) {
    return Container(
      width: 260.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(5.r)),
                  child: Text("عرض خاص",
                      style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                ),
                SizedBox(height: 5.h),
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 12.sp)),
              ],
            ),
          ),
          Icon(Icons.discount,
              color: Colors.white.withOpacity(0.3), size: 60.sp),
        ],
      ),
    );
  }

  // --- 🚦 نظام التوجيه المركزي (The Router) ---
  void _navigateToService(BuildContext context, String route) {
    Widget page;

    switch (route) {
      case 'clinics':
        page = ClinicsDepartmentScreen();
        break;

      case 'doctors':
        page = const DoctorsListScreen();
        break;

      case 'icu':
        // نمرر id المريض الحالي (يمكن جلبه من الـ Auth Provider)
        page = const IcuTimelineScreen(patientId: 'user_123');
        break;

      case 'labs':
        page = const LabsScreen();
        break;

      case 'radiology':
        page = const RadiologyScreen();
        break;

      case 'blood_bank':
        page = const BloodBankScreen();
        break;

      case 'pharmacy':
        page = const PharmacyScreen();
        break;

      case 'ambulance':
        page = const AmbulanceScreen();
        break;

      // الأقسام التي لم يتم إنشاؤها بعد تذهب لصفحة "قريباً"
      case 'surgeries':
        page = const SurgeriesScreen(); // ✅ تم التفعيل
        break;

      case 'incubators':
        page = const SmartIncubatorMain(); // ✅ تم التفعيل
        break;
      default:
        page = const ComingSoonScreen();
    }

    // الانتقال للشاشة
    Navigator.push(context, MaterialPageRoute(builder: (c) => page));
  }
}
