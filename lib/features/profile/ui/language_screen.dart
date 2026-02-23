import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // القيمة الافتراضية (مؤقتاً)
  String _selectedLang = 'ar'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("اللغة / Language", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildLanguageOption("العربية", "ar", "🇪🇬"),
            SizedBox(height: 15.h),
            _buildLanguageOption("English", "en", "🇺🇸"),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String code, String flag) {
    bool isSelected = _selectedLang == code;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLang = code);
        // 📡 هنا لاحقاً سنضع كود تغيير لغة التطبيق بالكامل
        // context.setLocale(Locale(code));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(code == 'ar' ? "تم تغيير اللغة للعربية" : "Language changed to English"))
        );
      },
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: isSelected ? const Color(0xFF005DA3) : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 15.w),
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF005DA3))
          ],
        ),
      ),
    );
  }
}