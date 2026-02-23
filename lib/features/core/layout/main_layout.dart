import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 👇 استدعاء الشاشات اللي عملناها قبل كده
import '../../../features/home/ui/home_screen.dart';
import '../../../features/chat/ui/messages_screen.dart';
import '../../../features/schedule/ui/schedule_screen.dart';
import '../../../features/profile/ui/patient_profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final Color mainColor = const Color(0xFF005DA3);

  // قائمة الشاشات بالترتيب
  final List<Widget> _screens = [
    const HomeScreen(),      // 0
    const MessagesScreen(),  // 1
    const ScheduleScreen(),  // 2
    const PatientProfileScreen(),   // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // عرض الشاشة الحالية
      body: _screens[_currentIndex],

      // الشريط السفلي (Bottom Navigation Bar)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, -5), // ظل خفيف لفوق
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed, // عشان الأيقونات ما تتحركش وتكبر
          backgroundColor: Colors.white,
          selectedItemColor: mainColor, // الأزرق لما تختار
          unselectedItemColor: Colors.grey.shade400, // رمادي لما ماتخترش
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12.sp),
          elevation: 0,
          items: [
            _buildNavItem(Icons.home_filled, "Home"),
            _buildNavItem(Icons.mail_outline, "Messages"),
            _buildNavItem(Icons.calendar_month_outlined, "Schedule"),
            _buildNavItem(Icons.person_outline, "Profile"),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء العناصر
  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 5.h), // مسافة صغيرة بين الأيقونة والنص
        child: Icon(icon, size: 24.sp),
      ),
      label: label,
    );
  }
}