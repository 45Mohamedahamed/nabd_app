import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ
import 'payment_success_dialog.dart'; // 👈 تأكد أن هذا الملف موجود

class BookAppointmentScreen extends StatefulWidget {
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final double rating;

  // قيم افتراضية للتجربة لو لم تمرر بيانات
  const BookAppointmentScreen({
    super.key,
    this.doctorName = "د. محمد علي",
    this.doctorImage = "assets/images/doctor1.png", // تأكد من وجود صورة
    this.specialty = "استشاري القلب والأوعية",
    this.rating = 4.8,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // الألوان الأساسية
  final Color mainColor = const Color(0xFF005DA3);
  final Color secondaryColor = const Color(0xFFF8F9FD);
  
  // المتغيرات
  int _selectedDateIndex = 0;
  int? _selectedTimeIndex;
  bool _isLoading = false;
  final TextEditingController _noteController = TextEditingController();

  // توليد الأيام الـ 14 القادمة
  final List<DateTime> _days = List.generate(14, (index) => DateTime.now().add(Duration(days: index)));

  // المواعيد المتاحة (صباحاً ومساءً)
  final List<String> _morningSlots = ["10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM", "12:00 PM"];
  final List<String> _eveningSlots = ["04:00 PM", "04:30 PM", "05:00 PM", "05:30 PM", "06:00 PM", "06:30 PM"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("حجز موعد", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. كارت الدكتور
                  FadeInDown(duration: const Duration(milliseconds: 500), child: _buildDoctorCard()),
                  
                  SizedBox(height: 25.h),

                  // 2. اختيار التاريخ (التقويم الأفقي)
                  FadeInLeft(duration: const Duration(milliseconds: 600), child: _buildSectionTitle("اختر التاريخ")),
                  SizedBox(height: 10.h),
                  FadeInLeft(duration: const Duration(milliseconds: 700), child: _buildHorizontalCalendar()),

                  SizedBox(height: 25.h),

                  // 3. اختيار الوقت
                  FadeInUp(duration: const Duration(milliseconds: 800), child: _buildSectionTitle("المواعيد المتاحة")),
                  SizedBox(height: 10.h),
                  _buildTimeSlots("الفترة الصباحية", _morningSlots, 0),
                  SizedBox(height: 10.h),
                  _buildTimeSlots("الفترة المسائية", _eveningSlots, _morningSlots.length),

                  SizedBox(height: 25.h),

                  // 4. مشكلة المريض
                  FadeInUp(duration: const Duration(milliseconds: 900), child: _buildSectionTitle("اكتب مشكلتك (اختياري)")),
                  SizedBox(height: 10.h),
                  _buildProblemInput(),
                ],
              ),
            ),
          ),

          // 5. زر الحجز السفلي
          _buildBottomBookingBar(),
        ],
      ),
    );
  }

  // --- 🎨 الـ Widgets الفرعية ---

  Widget _buildDoctorCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // الصورة
          Container(
            width: 80.w, height: 80.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              image: DecorationImage(image: AssetImage(widget.doctorImage), fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 15.w),
          // التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 5.h),
                Text(widget.specialty, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4.w),
                    Text("${widget.rating}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                    Text(" (450+ تقييم)", style: TextStyle(fontSize: 11.sp, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildHorizontalCalendar() {
    return SizedBox(
      height: 85.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _days.length,
        separatorBuilder: (c, i) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          bool isSelected = _selectedDateIndex == index;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDateIndex = index;
              _selectedTimeIndex = null; // إعادة تعيين الوقت عند تغيير اليوم
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60.w,
              decoration: BoxDecoration(
                color: isSelected ? mainColor : Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: isSelected ? mainColor : Colors.grey.shade300),
                boxShadow: isSelected ? [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(_days[index]), // رقم اليوم
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    DateFormat('EEE', 'ar').format(_days[index]), // اسم اليوم بالعربي
                    style: TextStyle(fontSize: 12.sp, color: isSelected ? Colors.white70 : Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots(String title, List<String> times, int offsetIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: List.generate(times.length, (index) {
            int actualIndex = index + offsetIndex;
            bool isSelected = _selectedTimeIndex == actualIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeIndex = actualIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? mainColor : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: isSelected ? mainColor : Colors.grey.shade300),
                ),
                child: Text(
                  times[index],
                  style: TextStyle(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProblemInput() {
    return TextField(
      controller: _noteController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "اشرح باختصار سبب الزيارة...",
        hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.all(15.w),
      ),
    );
  }

  Widget _buildBottomBookingBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("الإجمالي", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              Text("350 ج.م", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: mainColor)),
            ],
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  elevation: 5,
                  shadowColor: mainColor.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("تأكيد الحجز", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ⚙️ المنطق (Logic) ---

  void _confirmBooking() async {
    if (_selectedTimeIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار وقت الموعد أولاً"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // محاكاة الاتصال بالسيرفر
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      
      // ✅ فتح نافذة النجاح (مع البيانات الصحيحة لتجنب الأخطاء السابقة)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PaymentSuccessDialog(doctorName: "د. أحمد",), // تأكد أن هذا الكلاس لا يطلب بارامترات إجبارية في الكونستركتور، أو قم بتمريرها
      );
    }
  }
}