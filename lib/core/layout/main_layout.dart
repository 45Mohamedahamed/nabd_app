import 'package:flutter/material.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/profile/ui/patient_profile_screen.dart';
import '../../features/schedule/ui/schedule_screen.dart'; // 👇 الشاشة الجديدة

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final Color mainColor = const Color(0xFF005DA3);

  // قائمة الشاشات
  final List<Widget> _screens = [
    const HomeScreen(),     // 0: الرئيسية
    const ScheduleScreen(), // 1: مواعيدي
    const PatientProfileScreen(),  // 2: حسابي
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: mainColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "الرئيسية"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "مواعيدي"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
          ],
        ),
      ),
    );
  }
}