import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../model/radiology_model.dart';
import '../service/radiology_service.dart';
import 'radiology_tracking_screen.dart'; 
import '../model/radiology_model.dart';// استدعاء شاشة التتبع

class RadiologyScreen extends StatefulWidget {
  const RadiologyScreen({super.key});

  @override
  State<RadiologyScreen> createState() => _RadiologyScreenState();
}

class _RadiologyScreenState extends State<RadiologyScreen> {
  // متغيرات الحالة لإدارة الفلترة والتتبع
  String _selectedCategory = "الكل";
  Map<String, int> _bookedServicesSteps =
      {}; // بيانات التتبع الحية لربط الـ UI بالسيرفس
  final List<String> _categories = [
    "الكل",
    "R-Xray",
    "MRI رنين",
    "CT مقطعية",
    "Sonaar سونار",
    "PET مسح ذري"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("مركز الأشعة والمسح الذكي",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: StreamBuilder<List<RadiologyServiceModel>>(
              stream: RadiologyService().getRadiologyServices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF1A237E)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final services = snapshot.data!
                    .where((s) =>
                        _selectedCategory == "الكل" ||
                        s.category == _selectedCategory)
                    .toList();

                return ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: services.length,
                  itemBuilder: (context, index) =>
                      _buildServiceCard(services[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 1️⃣ كارت الخدمة الرئيسي (تم دمج التتبع والحجز فيه)
  Widget _buildServiceCard(RadiologyServiceModel service) {
    bool isBooked = _bookedServicesSteps.containsKey(service.id);
    int currentStep = _bookedServicesSteps[service.id] ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isBooked
            ? Border.all(color: const Color(0xFF1A237E), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(15.w),
            leading: _buildLeadingIcon(service.category, isBooked),
            title: Text(service.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
            subtitle: Text(service.preparation,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
            trailing: isBooked
                ? _buildLiveIndicator(currentStep)
                : Text("${service.price} ج.م",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          if (isBooked) _buildMiniTimeline(currentStep),
          Padding(
            padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isBooked
                    ? _buildStatusText(currentStep)
                    : Text("⚠️ ${service.category}",
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                _buildActionButton(service, isBooked, currentStep),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 2️⃣ منطق زر الحجز أو التتبع (الربط السحري)
  Widget _buildActionButton(RadiologyServiceModel service, bool isBooked, int step) {
    return ElevatedButton(
      onPressed: () {
        if (!isBooked) {
          _showBookingTicket(service); // إذا لم يحجز، افتح التذكرة الرقمية
        } else {
          // الانتقال لشاشة التتبع التفصيلية (Timeline)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RadiologyTrackingScreen(currentStep: step),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isBooked
            ? (step == 4 ? Colors.green : Colors.orange)
            : const Color(0xFF1A237E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      child: Text(
        isBooked ? (step == 4 ? "عرض النتيجة" : "تتبع الحالة") : "حجز الآن",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // 3️⃣ تذكرة الحجز الرقمية (Popup)
  void _showBookingTicket(RadiologyServiceModel service) {
    showDialog(
        context: context,
        builder: (context) => ZoomIn(
                child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("تذكرة حجز رقمية",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  const Divider(),
                  SizedBox(height: 10.h),
                  Icon(Icons.qr_code_2_rounded,
                      size: 100.sp, color: const Color(0xFF1A237E)),
                  SizedBox(height: 15.h),
                  _ticketRow("الفحص:", service.title),
                  _ticketRow("كود الحجز:",
                      "RAD-${service.id.substring(0, service.id.length > 3 ? 3 : service.id.length).toUpperCase()}99X"),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                      onPressed: () {
                        setState(() => _bookedServicesSteps[service.id] = 0);
                        RadiologyService().bookAppointment(
                            "user_123", service); // استدعاء السيرفس
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r))),
                      child: const Text("تأكيد التذكرة وحفظها",
                          style: TextStyle(color: Colors.white)))
                ],
              ),
            )));
  }

  // --- 🛠️ الدوال المساعدة (UI Helpers) ---
                             
  Widget _buildStatusText(int step) {
    List<String> statuses = [
      "تم تأكيد الحجز ✅",
      "في مرحلة التحضير ⏳",
      "جاري إجراء الفحص ☢️",
      "كتابة التقرير الطبي ✍️",
      "النتيجة جاهزة للاستلام 🎉"
    ];
    return Text(
      statuses[step],
      style: TextStyle(
          fontSize: 11.sp,
          color: const Color(0xFF1A237E),
          fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLeadingIcon(String category, bool active) {
    IconData iconData = Icons.document_scanner_outlined;
    if (category.contains("MRI"))
      iconData = Icons.settings_input_svideo_rounded;
    if (category.contains("CT")) iconData = Icons.donut_large_rounded;
    if (category.contains("Sonaar")) iconData = Icons.wifi_tethering;

    return CircleAvatar(
      backgroundColor: active ? const Color(0xFF1A237E) : Colors.indigo.shade50,
      child: Icon(iconData,
          color: active ? Colors.white : const Color(0xFF1A237E), size: 20.sp),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.all(8.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A237E) : Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: Colors.blue.withOpacity(0.2), blurRadius: 8)
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
     
  Widget _buildLiveIndicator(int step) {
    if (step == 4) return const Icon(Icons.check_circle, color: Colors.green);
    return Pulse(
        infinite: true,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8.r)),
          child: Text("LIVE",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold)),
        ));
  }

  Widget _buildMiniTimeline(int currentStep) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Row(
        children: List.generate(
            5,
            (index) => Expanded(
                  child: Container(
                    height: 4.h,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: index <= currentStep
                          ? const Color(0xFF1A237E)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                )),
      ),
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(children: [
        Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis))
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded, size: 60.sp, color: Colors.grey),
        const Text("لا توجد فحوصات في هذا القسم حالياً",
            style: TextStyle(color: Colors.grey)),
      ],
    ));
  }
}
