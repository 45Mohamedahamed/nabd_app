import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../home/ui/home_screen.dart'; // للرجوع للرئيسية
import '../../ambulance/ui/ambulance_screen.dart'; // لو حالة خطرة
import '../../doctors/ui/doctors_list_screen.dart'; // لو محتاج دكتور

class CheckupResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const CheckupResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    Color mainColor = resultData['color'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. الأيقونة الكبيرة
              Container(
                padding: EdgeInsets.all(30.w),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  mainColor == Colors.green ? Icons.check_circle : Icons.warning_rounded,
                  size: 80.sp,
                  color: mainColor,
                ),
              ),
              SizedBox(height: 30.h),

              // 2. العنوان والحالة
              Text(
                resultData['title'],
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: mainColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),

              // 3. التفاصيل
              Text(
                resultData['message'],
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25.h),

              // 4. كارت التوصية (أهم جزء)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber, size: 24.sp),
                        SizedBox(width: 10.w),
                        Text("التوصية الطبية:", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      resultData['recommendation'],
                      style: TextStyle(fontSize: 15.sp, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 5. زر الإجراء (يتغير حسب الحالة)
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: () => _handleAction(context, resultData['action']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  ),
                  child: Text(
                    _getButtonText(resultData['action']),
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              
              // زر الرجوع
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إجراء فحص جديد", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText(String action) {
    switch (action) {
      case 'call_ambulance': return "طلب إسعاف فوراً";
      case 'book_doctor': return "حجز موعد الآن";
      default: return "العودة للرئيسية";
    }
  }

  void _handleAction(BuildContext context, String action) {
    if (action == 'call_ambulance') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AmbulanceScreen()));
    } else if (action == 'book_doctor') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DoctorsListScreen()));
    } else {
      Navigator.pop(context); // رجوع للرئيسية
    }
  }
}