import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/ui/login_screen.dart'; // عشان لما يخلص يروح للدخول

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  final Color mainColor = const Color(0xFF005DA3);

  // بيانات الصفحات (ممكن تغير الصور والنصوص براحتك)
  final List<Map<String, String>> _contents = [
    {
      "image": "assets/images/1.png", // تأكد من وجود صور
      "title": "Find Trusted Doctors",
      "desc": "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of it over 2000 years old."
    },
    {
      "image": "assets/images/2.png",
      "title": "Choose Best Doctors",
      "desc": "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of it over 2000 years old."
    },
    {
      "image": "assets/images/3.png",
      "title": "Easy Appointments",
      "desc": "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of it over 2000 years old."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. زرار التخطي (Skip)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _navigateToLogin(),
                child: Text("Skip", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              ),
            ),
            
            // 2. المحتوى (PageView)
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _contents.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // دائرة خلفية للصورة
                        Container(
                          height: 250.h,
                          width: 250.w,
                          decoration: BoxDecoration(
                            color: mainColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.medical_services, size: 100.sp, color: mainColor), // أيقونة مؤقتة بدال الصورة
                          // child: Image.asset(_contents[index]["image"]!), // فك التعليق لما تحط الصور
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          _contents[index]["title"]!,
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          _contents[index]["desc"]!,
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. المؤشرات والزر (Footer)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // المؤشرات (Dots)
                  Row(
                    children: List.generate(
                      _contents.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  
                  // زر التالي أو البدء
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex == _contents.length - 1) {
                        _navigateToLogin();
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                    ),
                    child: Text(
                      _currentIndex == _contents.length - 1 ? "Get Started" : "Next",
                      style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء النقطة المتحركة
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5.w),
      height: 6.h,
      width: _currentIndex == index ? 20.w : 6.w, // تكبير العرض لو نشط
      decoration: BoxDecoration(
        color: _currentIndex == index ? mainColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
  }
}