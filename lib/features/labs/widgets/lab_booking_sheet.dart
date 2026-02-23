import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/labs/model/lab_test_model.dart';
import '../../../features/labs/service/lab_booking_service.dart';
import '../../labs/ui/lab_result_tracking_screen.dart'; // 👈 تأكد من استدعاء شاشة التتبع هنا

class LabBookingSheet extends StatefulWidget {
  final List<LabTestModel> labCart;
  final VoidCallback onBookingComplete;

  const LabBookingSheet({
    super.key,
    required this.labCart,
    required this.onBookingComplete,
  });

  @override
  State<LabBookingSheet> createState() => _LabBookingSheetState();
}

class _LabBookingSheetState extends State<LabBookingSheet> {
  final TextEditingController _addressController = TextEditingController();
  final bool _isHomeVisit = true;

  @override
  Widget build(BuildContext context) {
    double totalTestsPrice = widget.labCart.fold(0.0, (s, item) => s + item.price);
    double homeVisitFees = _isHomeVisit ? 100.0 : 0.0;

    return Container(
      padding: EdgeInsets.all(20.w),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40.w, height: 4.h, color: Colors.grey.shade300)),
          SizedBox(height: 20.h),
          Text("تأكيد حجز المختبر 🩸",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6A1B9A))),
          
          const Divider(height: 30),

          // قائمة التحاليل
          Expanded(
            child: ListView.builder(
              itemCount: widget.labCart.length,
              itemBuilder: (context, i) => ListTile(
                leading: const Icon(Icons.science, color: Colors.purple),
                title: Text(widget.labCart[i].title, style: TextStyle(fontSize: 13.sp)),
                trailing: Text("${widget.labCart[i].price} ج.م"),
              ),
            ),
          ),

          // حقل العنوان
          Text("عنوان الزيارة المنزلية:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: "اسم الشارع، رقم العمارة، الشقة...",
              prefixIcon: const Icon(Icons.location_on, color: Colors.purple),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          SizedBox(height: 20.h),

          // التكلفة
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(15.r)),
            child: Column(
              children: [
                _priceRow("إجمالي التحاليل", "$totalTestsPrice"),
                _priceRow("رسوم الزيارة", "$homeVisitFees"),
                const Divider(),
                _priceRow("الإجمالي النهائي", "${totalTestsPrice + homeVisitFees}", isBold: true),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // زر التأكيد
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              onPressed: () => _handleBooking(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))),
              child: Text("تأكيد الطلب الآن",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
            ),
          )
        ],
      ),
    );
  }

  Widget _priceRow(String label, String price, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("$price ج.م", style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.purple : Colors.black)),
        ],
      ),
    );
  }

  void _handleBooking(BuildContext context) async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال العنوان بالتفصيل 📍")));
      return;
    }

    // إظهار Loading
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator(color: Colors.purple)));

    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "guest_user";
      
      // 1. استدعاء السيرفيس وتخزين رقم الحجز العائد
      String bookingId = await LabBookingService().checkoutLabCart(
        userId: uid,
        selectedTests: widget.labCart,
        isHomeVisit: true,
        address: {'details': _addressController.text},
      );

      if (mounted) {
        Navigator.pop(context); // إغلاق الـ Loading
        Navigator.pop(context); // إغلاق الـ BottomSheet
        
        widget.onBookingComplete(); // تفريغ السلة في الشاشة الرئيسية

        // 2. الانتقال المباشر لشاشة تتبع النتيجة باستخدام الـ ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => LabResultTrackingScreen(bookingId: bookingId),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم الحجز بنجاح! جاري تحويلك لمتابعة الطلب... 🚀"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      Navigator.pop(context); // إغلاق الـ Loading في حالة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    }
  }
}