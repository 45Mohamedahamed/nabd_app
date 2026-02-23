import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 👇 بتروح لصفحة الترحيب
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  // 🎨 اللون الأزرق الملكي
  final Color mainColor = const Color(0xFF005DA3);

  // البيانات (كلام وصور)
  final List<Map<String, String>> contents = [
    {
      "title": "ابحث عن دكتورك",
      "desc": "اختار من بين آلاف الأطباء المتخصصين في كل المجالات بضغطة زر.",
      "image": "assets/images/1.png"
    },
    {
      "title": "استشارة أونلاين",
      "desc": "تواصل مع طبيبك صوت وصورة من بيتك من غير ما تنزل.",
      "image": "assets/images/2.png"
    },
    {
      "title": "احجز موعدك",
      "desc": "احجز ميعاد الكشف المناسب ليك وتجنب الانتظار في العيادات.",
      "image": "assets/images/3.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // زر تخطي
          TextButton(
            onPressed: () => _goToWelcome(),
            child: Text("تخطي", style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. الجزء المتحرك (الصور والكلام)
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (index) => setState(() => currentIndex = index),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 👇👇👇 التعديل هنا: الصورة تملأ الدائرة بالكامل 👇👇👇
                      Expanded(
                        child: Container(
                          // شلنا الـ padding عشان الصورة تلمس الحواف
                          decoration: BoxDecoration(
                            color: mainColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval( // عشان يقص الصورة دايرة
                            child: Image.asset(
                              contents[index]["image"]!,
                              fit: BoxFit.cover, // ✅ دي اللي بتخليها تملأ المكان كله
                              width: double.infinity, // تاخد العرض كله
                              height: double.infinity, // تاخد الطول كله
                              
                              // لو الصورة مش موجودة
                              errorBuilder: (c, e, s) => Center(
                                child: Icon(
                                  Icons.image_not_supported, 
                                  size: 50.sp, 
                                  color: mainColor
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 👆👆👆 --------------------------------------- 👆👆👆

                      SizedBox(height: 30.h),
                      Text(
                        contents[index]["title"]!,
                        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        contents[index]["desc"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 2. المؤشر والزرار
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // النقاط (Dots)
                Row(
                  children: List.generate(
                    contents.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: 5.w),
                      height: 8.h,
                      width: currentIndex == index ? 25.w : 8.w,
                      decoration: BoxDecoration(
                        color: currentIndex == index ? mainColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                  ),
                ),
                
                // زر التالي / ابدأ
                ElevatedButton(
                  onPressed: () {
                    if (currentIndex == contents.length - 1) {
                      _goToWelcome();
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.all(15.w),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }
}