import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

// 👇 استدعاء الشاشات الفرعية والسيرفيس بالمسارات الصحيحة
import 'medicines_screen.dart';
import 'vitamins_screen.dart';
import 'care_screen.dart';
import 'equipment_screen.dart';
import '../service/pharmacy_service.dart'; 
import '../ui/orders_screen.dart';// تأكد من أن المجلد اسمه services بالـ s

class PharmacyScreen extends StatelessWidget {
  final bool isAdmin;
  
  // جعل isAdmin افتراضياً true لتسهيل الاختبار، ويمكن التحكم بها عند الاستدعاء
  const PharmacyScreen({super.key, this.isAdmin = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
     appBar: AppBar(
  title: const Text(
    "الصيدلية الإلكترونية",
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  centerTitle: true,
  backgroundColor: Colors.white,
  elevation: 0,
  iconTheme: const IconThemeData(color: Colors.black),
  actions: [
    // 1️⃣ زر سجل الطلبات - مع تمرير isAdmin عشان لو الشاشة محتاجاه
    IconButton(
      icon: const Icon(Icons.history, color: Colors.blueGrey),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
  // نمرر المتغير isAdmin الحالي لضمان استمرار الصلاحية
       builder: (c) => OrdersScreen(isAdmin: isAdmin), 
        ),
      ),
    ),
    
    // 2️⃣ زر السلة
    IconButton(
      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
  // حذفنا const لأننا سنمرر isAdmin
      builder: (c) => CareScreen(isAdmin: isAdmin), 
        ),
      ),
    ),
    SizedBox(width: 8.w),
  ],
),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1️⃣ بانر ترويجي جذاب باستخدام أنيميشن
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                height: 140.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF009688), Color(0xFF80CBC4)],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "خصومات تصل لـ 30%",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "على جميع منتجات العناية بالبشرة",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.local_offer,
                      color: Colors.white.withOpacity(0.8),
                      size: 60.sp,
                    ),
                  ],
                ),
              ),
            ),
            
            // 2️⃣ الزر السحري: يظهر للأدمن فقط لرفع البيانات المبدئية للفايربيز
            if (isAdmin)
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: const Icon(Icons.cloud_upload, color: Colors.white),
                      label: const Text(
                        "رفع البيانات للفايربيز (Setup)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await PharmacyService().uploadAllMockData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ تم رفع البيانات بنجاح!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("❌ حدث خطأ: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),

            SizedBox(height: 15.h),
            Text(
              "تصفح الأقسام",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15.h),

            // 3️⃣ شبكة الأقسام: تمرير isAdmin لكل شاشة بشكل إلزامي لحل أخطاء الـ Constructor
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15.w,
              mainAxisSpacing: 15.h,
              childAspectRatio: 1.1,
              children: [
                _buildCategoryCard(
                  context,
                  "الأدوية",
                  Icons.medication,
                  Colors.blue,
                  MedicinesScreen(isAdmin: isAdmin),
                ),
                _buildCategoryCard(
                  context,
                  "الفيتامينات",
                  Icons.wb_sunny,
                  Colors.orange,
                  VitaminsScreen(isAdmin: isAdmin),
                ),
                _buildCategoryCard(
                  context,
                  "العناية",
                  Icons.face,
                  Colors.pink,
                  CareScreen(isAdmin: isAdmin),
                ),
                _buildCategoryCard(
                  context,
                  "أجهزة طبية",
                  Icons.monitor_heart,
                  Colors.green,
                  EquipmentScreen(isAdmin: isAdmin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت بناء بطاقة القسم بلمسة جمالية
  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          // الانتقال إلى الشاشة الفرعية مع الحفاظ على سياق الـ isAdmin
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => destination),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}