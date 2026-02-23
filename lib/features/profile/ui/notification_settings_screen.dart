import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // متغيرات للتحكم في المفاتيح
  bool _medicationReminders = true;
  bool _doctorUpdates = true;
  bool _appOffers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("إعدادات الإشعارات", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildSwitchTile("تذكير الأدوية", "تنبيهات بمواعيد الجرعات اليومية", _medicationReminders, (val) {
              setState(() => _medicationReminders = val);
            }),
            _buildSwitchTile("تحديثات الطبيب", "إشعارات عند رد الطبيب أو تغيير الموعد", _doctorUpdates, (val) {
              setState(() => _doctorUpdates = val);
            }),
            _buildSwitchTile("نصائح وعروض", "نصائح صحية عامة وأخبار التطبيق", _appOffers, (val) {
              setState(() => _appOffers = val);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
      ),
      child: SwitchListTile(
        activeColor: const Color(0xFF005DA3),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}