import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/chat/ui/chat_screen.dart'; // تأكد من مسار شاشة الشات

class SmartChatButton extends StatefulWidget {
  const SmartChatButton({super.key});

  @override
  State<SmartChatButton> createState() => _SmartChatButtonState();
}

class _SmartChatButtonState extends State<SmartChatButton> with SingleTickerProviderStateMixin {
  // متغيرات الأنيميشن
  bool isOpened = false;
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    // تجهيز الأنيميشن (مدته 300 مللي ثانية)
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    
    // أنيميشن الدوران (عشان الزر يلف ويبقى علامة X)
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // أنيميشن الحركة للأزرار الفرعية
    _translateAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // دالة الفتح والغلق
  void animate() {
    setState(() {
      isOpened = !isOpened;
      isOpened ? _animationController.forward() : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end, // محاذاة لليمين
      children: [
        // 1. زر "مجموعة جديدة" (يظهر لما القائمة تفتح)
        _buildOptionButton(
          label: "مجموعة جديدة",
          icon: Icons.group_add,
          color: Colors.purple,
          onTap: () {
            animate(); // اقفل القائمة
            // هنا كود الانتقال لصفحة إنشاء مجموعة
          },
        ),
        
        // 2. زر "محادثة خاصة" (يظهر لما القائمة تفتح)
        _buildOptionButton(
          label: "محادثة خاصة",
          icon: Icons.person_add,
          color: Colors.green,
          onTap: () {
            animate();
            // الانتقال للشات العادي
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatScreen(
      // 👇 هنا بنبعت بيانات الدكتور اللي تم الحجز معاه
      receiverName: "د. أحمد", // المفروض تكون جاية من بيانات الحجز
      receiverImage: "assets/images/doctor2.png",
      chatId: "booking_${DateTime.now().millisecondsSinceEpoch}", // ID فريد للحجز
    ),
  ),
);          },
        ),

        SizedBox(height: 10.h),

        // 3. الزر الرئيسي (الأزرق)
        FloatingActionButton(
          onPressed: animate,
          backgroundColor: const Color(0xFF005DA3),
          child: RotationTransition(
            turns: _rotateAnimation,
            child: Icon(
              isOpened ? Icons.add : Icons.chat_bubble_outline, // الأيقونة تتغير
              color: Colors.white, 
              size: 28.sp,
            ),
          ),
        ),
      ],
    );
  }

  // ويدجت صغيرة للأزرار الفرعية
  Widget _buildOptionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizeTransition(
      sizeFactor: _translateAnimation,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // النص اللي بيظهر جنب الزر
            Material(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ),
            ),
            SizedBox(width: 10.w),
            // الزر الصغير
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)]),
                child: Icon(icon, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}