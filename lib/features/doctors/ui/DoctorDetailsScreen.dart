import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clinics/model/doctor_model.dart';
import '../../clinics/service/clinic_service.dart';
import '../../notification_services/services/notification_service.dart';
import '../../clinics/service/stripe_service.dart';
class DoctorDetailsScreen extends StatefulWidget {
  final DoctorModel doctor;
  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  // 1️⃣ متغيرات الحالة (State)
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;

  // 2️⃣ متغيرات الفورم (Form Data)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 3️⃣ إعدادات الوقت والتاريخ
  final List<DateTime> _nextDays =
      List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
  final List<String> _timeSlots = [
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "01:00 PM",
    "01:30 PM",
    "02:00 PM",
    "02:30 PM",
    "04:00 PM",
    "04:30 PM",
    "05:00 PM",
    "05:30 PM",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // 🔥 [Logic Core] دالة مراقبة المواعيد لحظياً من الفايربيز
  Stream<List<String>> _getBookedSlotsStream(DateTime date) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctor.id)
        .where('appointmentDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointmentDate', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc['appointmentTime'] as String)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        slivers: [
          // 🎨 الهيدر الفخم (SliverAppBar)
          SliverAppBar(
            expandedHeight: 280.h,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.doctor.imageUrl.isNotEmpty
                        ? widget.doctor.imageUrl
                        : 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 50)),
                  ),
                  // طبقة تظليل للنص
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20.h,
                    left: 20.w,
                    right: 20.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctor.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold)),
                        Text(widget.doctor.specialty,
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14.sp)),
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            SizedBox(width: 5.w),
                            Text(
                                "${widget.doctor.rating} (${widget.doctor.reviewsCount} تقييم)",
                                style: const TextStyle(color: Colors.white)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(20.h),
              child: Container(
                height: 20.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
              ),
            ),
          ),

          // 📝 محتوى الصفحة
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // أ) كروت الإحصائيات
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard(
                            "المرضى",
                            "+${widget.doctor.patientsCount}",
                            Icons.people_outline,
                            Colors.blue),
                        _buildStatCard(
                            "الخبرة",
                            "${widget.doctor.experienceYears} سنوات",
                            Icons.work_outline,
                            Colors.orange),
                        _buildStatCard("السعر", "${widget.doctor.price}\$",
                            Icons.monetization_on_outlined, Colors.green),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),

                  // ب) نبذة عن الطبيب
                  Text("عن الطبيب",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text(widget.doctor.about,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.5,
                          fontSize: 13.sp)),
                  SizedBox(height: 25.h),

                  // ج) شريط اختيار اليوم
                  Text("جدول المواعيد",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15.h),
                  SizedBox(
                    height: 80.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _nextDays.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedDateIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedDateIndex = index;
                            _selectedTimeIndex =
                                -1; // إعادة تعيين الوقت عند تغيير اليوم
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(right: 10.w),
                            width: 60.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1A237E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.shade300),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: Colors.indigo.withOpacity(0.3),
                                          blurRadius: 10)
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(DateFormat('d').format(_nextDays[index]),
                                    style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black)),
                                Text(DateFormat('E').format(_nextDays[index]),
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // د) شبكة المواعيد الذكية (Smart Grid)
                  Text("المواعيد المتاحة",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.h),

                  StreamBuilder<List<String>>(
                      stream:
                          _getBookedSlotsStream(_nextDays[_selectedDateIndex]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator()));
                        }

                        List<String> bookedTimes = snapshot.data ?? [];

                        return Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: List.generate(_timeSlots.length, (index) {
                            String time = _timeSlots[index];
                            bool isBooked = bookedTimes.contains(time);
                            bool isSelected = _selectedTimeIndex == index;

                            return AbsorbPointer(
                              absorbing: isBooked, // 🛑 منع الضغط لو محجوز
                              child: InkWell(
                                onTap: isBooked
                                    ? null
                                    : () => setState(
                                        () => _selectedTimeIndex = index),
                                borderRadius: BorderRadius.circular(10.r),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1A237E)
                                        : (isBooked
                                            ? Colors.grey.shade200
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : (isBooked
                                                ? Colors.transparent
                                                : Colors.grey.shade300)),
                                  ),
                                  child: Text(
                                    isBooked ? "$time (ممتلئ)" : time,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      decoration: isBooked
                                          ? TextDecoration.lineThrough
                                          : null, // ❌ شطب
                                      color: isSelected
                                          ? Colors.white
                                          : (isBooked
                                              ? Colors.grey
                                              : Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔘 الزر العائم (يفتح الفورم)
      bottomSheet: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55.h,
          child: ElevatedButton(
            // لو لم يتم اختيار وقت، الزر معطل. لو تم الاختيار، نفتح الفورم.
            onPressed: _selectedTimeIndex == -1 ? null : _showBookingForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r)),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text("استكمال البيانات والحجز",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // 📝 نافذة إدخال البيانات (BottomSheet Form)
  void _showBookingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // لرفع النافذة عند فتح الكيبورد
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
        ),
        padding: EdgeInsets.fromLTRB(
            25.w, 10.h, 25.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 50.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10))),
                SizedBox(height: 20.h),
                Text("تأكيد بيانات المريض 📝",
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A237E))),
                SizedBox(height: 20.h),

                // حقل الاسم
                TextFormField(
                  controller: _nameController,
                  validator: (val) => val!.isEmpty ? "يرجى كتابة الاسم" : null,
                  decoration: InputDecoration(
                    labelText: "الاسم بالكامل",
                    prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                SizedBox(height: 15.h),

                // حقل الهاتف
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                      val!.length < 11 ? "رقم الهاتف غير صحيح" : null,
                  decoration: InputDecoration(
                    labelText: "رقم الهاتف",
                    prefixIcon: const Icon(Icons.phone, color: Colors.indigo),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                SizedBox(height: 15.h),

                // حقل الملاحظات
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "ملاحظات للطبيب (اختياري)",
                    hintText: "أشكو من...",
                    alignLabelWithHint: true,
                    prefixIcon:
                        const Icon(Icons.note_alt, color: Colors.indigo),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                SizedBox(height: 25.h),

                // زر التأكيد النهائي
                SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton(
                    onPressed: _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r)),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10.w),
                        Text("تأكيد الحجز النهائي",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🚀 تنفيذ الحجز في الفايربيز
 void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. نطلب الدفع أولاً
    bool paymentSuccessful = await StripeService.makePayment(
      amount: (widget.doctor.price * 100).toInt().toString(), // المبلغ بالقرش/السنت
      currency: "USD",
    );

    if (paymentSuccessful) {
      // 2. لو الدفع نجح، كمل عملية التسجيل في الفايربيز
      showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
      
      try {
        // ... (كود الحجز في الفايربيز اللي عملناه قبل كدة) ...
        
        // 3. نرسل إشعار النجاح
        await NotificationService().showInstantNotification(
          title: "تم الدفع والحجز بنجاح ✅",
          body: "تم دفع ${widget.doctor.price}ج.م وتأكيد موعدك.",
        );
      } catch (e) {
        //处理错误
      }
    } else {
      // لو قفل الشاشة أو الدفع فشل
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("عملية الدفع لم تكتمل ❌"), backgroundColor: Colors.red),
      );
    }
  }
  // ويدجت مساعدة للإحصائيات
  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
        ],
      ),
    );
  }
}
