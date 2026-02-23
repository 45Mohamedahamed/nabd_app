import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'payment_success_dialog.dart'; // 👇 الملف اللي هنعمله في الخطوة الجاية

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final Color mainColor = const Color(0xFF005DA3);
  
  // داتا وهمية للتحكم في الاختيار
  int _selectedDay = 1; 
  int _selectedTime = 2;

  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final List<String> dateNums = ["21", "22", "23", "24", "25", "26"];
  final List<String> times = [
    "09:00 AM", "10:00 AM", "11:00 AM", 
    "01:00 PM", "02:00 PM", "03:00 PM", 
    "04:00 PM", "07:00 PM", "08:00 PM"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Appointment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ كارت الدكتور (ملخص سريع)
            _buildDoctorSummaryCard(),
            
            SizedBox(height: 30.h),

            // 2️⃣ اختيار التاريخ (Date Selector)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Text("Change", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
            SizedBox(height: 15.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(days.length, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = index),
                    child: Container(
                      margin: EdgeInsets.only(right: 15.w),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                      decoration: BoxDecoration(
                        color: _selectedDay == index ? mainColor : Colors.white, // 🔵 التغيير هنا
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: _selectedDay == index ? mainColor : Colors.grey.shade200),
                        boxShadow: _selectedDay == index 
                            ? [BoxShadow(color: mainColor.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Text(days[index], style: TextStyle(color: _selectedDay == index ? Colors.white70 : Colors.grey, fontSize: 12.sp)),
                          SizedBox(height: 5.h),
                          Text(dateNums[index], style: TextStyle(color: _selectedDay == index ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: 25.h),

            // 3️⃣ سبب الزيارة (Reason)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Reason", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                Text("Change", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_note, color: mainColor),
                  SizedBox(width: 10.w),
                  Text("Chest pain", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            SizedBox(height: 25.h),

            // 4️⃣ تفاصيل الدفع (Payment Detail)
            Text("Payment Detail", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 15.h),
            _buildPaymentRow("Consultation", "\$60.00"),
            _buildPaymentRow("Admin Fee", "\$01.00"),
            _buildPaymentRow("Additional Discount", "-", isDiscount: true),
            Divider(height: 30.h, color: Colors.grey.shade300),
            _buildPaymentRow("Total", "\$61.00", isTotal: true),

            SizedBox(height: 25.h),

            // 5️⃣ طريقة الدفع (Payment Method)
            Text("Payment Method", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(5.r)),
                        child: Text("VISA", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                      ),
                      SizedBox(width: 15.w),
                      Text("**** **** **** 2512", style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  TextButton(onPressed: (){}, child: Text("Change", style: TextStyle(color: Colors.grey.shade500)))
                ],
              ),
            ),
            
            SizedBox(height: 40.h),

            // زر الحجز النهائي
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: () {
                  // هنا بنظهر الـ Dialog بتاع النجاح
                 // ✅ الحل: مرر اسم الدكتور (حتى لو اسم وهمي مؤقتاً)
                    showDialog(
                         context: context,
                      builder: (context) => const PaymentSuccessDialog(
                    doctorName: "د. سارة أحمد", // 👈 ضيف السطر ده
                    ),
                     );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  elevation: 5,
                  shadowColor: mainColor.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: Text("Total \$61.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    ),
                    Text("Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    SizedBox(width: 20.w), // عشان التوسيط يبقى شكله حلو
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت ملخص الدكتور
  Widget _buildDoctorSummaryCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            height: 70.h, width: 70.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.grey.shade200,
              // image: const DecorationImage(image: AssetImage('assets/images/doctor1.png'), fit: BoxFit.cover),
            ),
            child: Icon(Icons.person, color: Colors.grey, size: 40.sp),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dr. Marcus Horizon", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text("Chardiologist", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              SizedBox(height: 5.h),
              Row(
                children: [
                  Icon(Icons.star, color: mainColor, size: 14.sp),
                  Text(" 4.7", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                  SizedBox(width: 5.w),
                  Icon(Icons.location_on, color: Colors.grey, size: 14.sp),
                  Text(" 800m away", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  // ويدجت صف الدفع
  Widget _buildPaymentRow(String title, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: isTotal ? Colors.black : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: 14.sp)),
          Text(value, style: TextStyle(
            color: isTotal ? mainColor : (isDiscount ? Colors.green : Colors.black), 
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, 
            fontSize: isTotal ? 16.sp : 14.sp
          )),
        ],
      ),
    );
  }
}