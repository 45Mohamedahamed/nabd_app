import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../doctors/ui/doctors_list_screen.dart'; // استدعاء شاشة قائمة الأطباء

// 1. موديل بسيط خاص بواجهة الأقسام فقط (للعرض)
class ClinicCategory {
  final String name;
  final String desc;
  final IconData icon;
  final Color color;

  ClinicCategory(this.name, this.desc, this.icon, this.color);
}

class ClinicsDepartmentScreen extends StatelessWidget {
  ClinicsDepartmentScreen({super.key});

  // 2. قائمة البيانات الثابتة (للعرض الفخم)
  final List<ClinicCategory> _clinics = [
    ClinicCategory("باطنة", "الجهاز الهضمي والكبد", Icons.accessibility_new, Colors.blue),
    ClinicCategory("أسنان", "تجميل وزراعة الأسنان", Icons.sentiment_very_satisfied, Colors.orange),
    ClinicCategory("عظام", "الكسور والمفاصل", Icons.accessible, Colors.purple),
    ClinicCategory("عيون", "الليزك والرمد", Icons.remove_red_eye, Colors.green),
    ClinicCategory("قلب", "رسم القلب والقسطرة", Icons.favorite, Colors.red),
    ClinicCategory("جلدية", "ليزر وتجميل", Icons.face, Colors.pink),
    ClinicCategory("أطفال", "حديثي الولادة", Icons.child_care, Colors.cyan),
    ClinicCategory("أنف وأذن", "سمعيات واتزان", Icons.hearing, Colors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // سكرول ناعم
        slivers: [
          // 3. الهيدر الفخم المتحرك (SliverAppBar)
          SliverAppBar(
            expandedHeight: 160.h,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_hospital_rounded, size: 50.sp, color: Colors.white24),
                      SizedBox(height: 10.h),
                      Text(
                        "الأقسام الطبية",
                        style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "اختر القسم لعرض الأطباء المتاحين",
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. شبكة العيادات (Grid)
          SliverPadding(
            padding: EdgeInsets.all(15.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // عمودين
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.h,
                childAspectRatio: 0.9, // نسبة الطول للعرض
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 50 * index), // أنيميشن متتابع
                    child: _buildClinicCard(context, _clinics[index]),
                  );
                },
                childCount: _clinics.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. تصميم الكارت (بدون لوجيك معقد)
  Widget _buildClinicCard(BuildContext context, ClinicCategory clinic) {
    return GestureDetector(
      onTap: () {
        // 🚀 الربط هنا: عند الضغط نذهب لشاشة الأطباء
        Navigator.push(
          context,
          MaterialPageRoute(
            // هنا بنمرر اسم القسم عشان الشاشة التانية تفلتر عليه (لو انت مجهزها)
            // ولو لسه مش مجهزها، الكود ده هيفتح الشاشة زي ما هي
            builder: (context) => DoctorsListScreen(initialCategory: clinic.name),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
          ],
          border: Border.all(color: clinic.color.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // دائرة الأيقونة
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: clinic.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(clinic.icon, color: clinic.color, size: 32.sp),
            ),
            SizedBox(height: 15.h),
            
            // الاسم
            Text(
              clinic.name,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 5.h),
            
            // الوصف
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                clinic.desc,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}