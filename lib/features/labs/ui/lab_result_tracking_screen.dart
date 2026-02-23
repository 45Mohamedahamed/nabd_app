import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LabResultTrackingScreen extends StatelessWidget {
  final String bookingId; // معرف الحجز اللي اتعمل في الخطوة اللي فاتت

  const LabResultTrackingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("تتبع عينة التحليل", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('lab_bookings').doc(bookingId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("لا توجد بيانات لهذا الحجز"));
          }

          // استخراج البيانات وتحويل الحالة لرقم (0-4)
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String status = data['status'] ?? 'pending';
          int currentStep = _getStatusStep(status);
          String? reportUrl = data['reportUrl']; // رابط الـ PDF لو موجود

          return Padding(
            padding: EdgeInsets.all(25.w),
            child: Column(
              children: [
                // 1. تفاصيل سريعة
                _buildHeaderInfo(data),
                const Divider(height: 30),

                // 2. التايم لاين (Timeline)
                Expanded(
                  child: ListView(
                    children: [
                      _buildStep(0, currentStep, "تم تأكيد الحجز", "الفني يراجع موقعك الجغرافي", Icons.verified),
                      _buildLine(0, currentStep),
                      _buildStep(1, currentStep, "الفني في الطريق", "سيصلك لسحب العينة قريباً", Icons.two_wheeler),
                      _buildLine(1, currentStep),
                      _buildStep(2, currentStep, "تم سحب العينة", "العينة في طريقها للمختبر المركزي", Icons.bloodtype),
                      _buildLine(2, currentStep),
                      _buildStep(3, currentStep, "جاري التحليل", "يتم فحص العينة الآن بدقة", Icons.biotech),
                      _buildLine(3, currentStep),
                      _buildStep(4, currentStep, "النتيجة جاهزة", "التقرير متاح للتحميل PDF", Icons.task_alt),
                    ],
                  ),
                ),

                // 3. زر تحميل النتيجة (يظهر فقط في المرحلة الأخيرة)
                if (currentStep == 4)
                  FadeInUp(
                    child: SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadPDF(context, reportUrl),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                        label: const Text("تحميل نتيجة التحليل (PDF)", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // أخضر للنجاح
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                        ),
                      ),
                    ),
                  )
                else
                  _buildStatusMessage(status),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- دوال المساعدة (UI Logic) ---

  // تحويل الحالة النصية من الفايربيز لرقم خطوة
  int _getStatusStep(String status) {
    switch (status) {
      case 'pending': return 0;
      case 'technician_assigned': return 1;
      case 'samples_collected': return 2;
      case 'analyzing': return 3;
      case 'completed': return 4;
      default: return 0;
    }
  }

  Widget _buildStep(int index, int currentStep, String title, String sub, IconData icon) {
    bool isDone = currentStep >= index;
    bool isCurrent = currentStep == index;

    return FadeInLeft(
      delay: Duration(milliseconds: index * 200),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF6A1B9A) : Colors.grey[200],
                  shape: BoxShape.circle,
                  boxShadow: isCurrent ? [BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 10)] : [],
                ),
                child: Icon(icon, color: isDone ? Colors.white : Colors.grey, size: 24.sp),
              ),
            ],
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: isDone ? Colors.black : Colors.grey)),
                SizedBox(height: 5.h),
                Text(sub, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                SizedBox(height: 20.h), // مسافة للخطوة اللي بعدها
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLine(int index, int currentStep) {
    return Container(
      margin: EdgeInsets.only(right: 22.w), // محاذاة الخط مع الدائرة
      height: 30.h,
      width: 2.w,
      color: currentStep > index ? const Color(0xFF6A1B9A) : Colors.grey[300],
    );
  }

  Widget _buildHeaderInfo(Map<String, dynamic> data) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("رقم العينة", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              Text("#${data['bookingId'].toString().substring(0, 6).toUpperCase()}", 
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6A1B9A))),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
            child: Text(data['isHomeVisit'] ? "زيارة منزلية 🏠" : "في المعمل 🏥",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.black87)),
          )
        ],
      ),
    );
  }

  Widget _buildStatusMessage(String status) {
    String msg = "جاري معالجة طلبك...";
    if (status == 'technician_assigned') msg = "الفني في الطريق إليك، يرجى الاستعداد.";
    if (status == 'analyzing') msg = "يتم تحليل العينة الآن في المختبر.";
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10.w),
          Text(msg, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // 📥 دالة فتح الـ PDF
  void _downloadPDF(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("التقرير غير متاح حالياً ⚠️")));
      return;
    }
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
  }
}