import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// 👇 تأكد إنك عامل import لملفات الشاشات دي صح
import '../../features/emergency/ui/emergency_screen.dart';
import '../../features/chat/ui/chat_screen.dart';
import '../../features/appointmen/ui/book_appointment_screen.dart';

class CreativeFabMenu extends StatefulWidget {
  const CreativeFabMenu({super.key});

  @override
  State<CreativeFabMenu> createState() => _CreativeFabMenuState();
}

class _CreativeFabMenuState extends State<CreativeFabMenu> {
  final Color mainColor = const Color(0xFF005DA3);
  ValueNotifier<bool> isOpen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.close_rounded,
      backgroundColor: mainColor,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.redAccent,
      buttonSize: Size(65.w, 65.w),
      childrenButtonSize: Size(60.w, 60.w),
      iconTheme: IconThemeData(size: 30.sp),
      visible: true,
      curve: Curves.elasticInOut,
      overlayColor: Colors.black,
      overlayOpacity: 0.7,
      elevation: 12.0,
      shape: const CircleBorder(),
      spacing: 15,
      spaceBetweenChildren: 10,
      onOpen: () => HapticFeedback.mediumImpact(),
      onClose: () => HapticFeedback.lightImpact(),
      children: [
        // 🚨 الطوارئ
        SpeedDialChild(
          child: const Icon(Icons.emergency_share, color: Colors.white),
          backgroundColor: Colors.red.shade700,
          label: 'استغاثة فورية (SOS)',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red), // شيلنا const من هنا لو عملت مشاكل
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const EmergencyScreen()));
          },
        ),

        // 🏠 زيارة منزلية (غيرنا الأيقونة لـ home بس عشان القديمة مش عندك)
        SpeedDialChild(
          child: const Icon(Icons.home, color: Colors.white), // ✅ تم التعديل
          backgroundColor: const Color(0xFFE91E63),
          label: 'كشف منزلي',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
          labelBackgroundColor: Colors.white,
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("قريباً...")));
          },
        ),

        // 🤖 مساعد ذكي
        SpeedDialChild(
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
          backgroundColor: Colors.indigo,
          label: 'المساعد الطبي (AI)',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.indigo),
          labelBackgroundColor: Colors.white,
          onTap: () {
            // ✅ تم إضافة doctorName عشان يحل مشكلة الصورة الأولى
            Navigator.push(
                   context,
                 MaterialPageRoute(
                  builder: (context) => ChatScreen(
                 // 👇 بنبعت البيانات اللي جاية للزر ده
                 receiverName: "الدعم الفني", // أو المتغير اللي عندك
                 receiverImage: "assets/images/support.png", 
                 chatId: "support_chat_001",
               ),
             ),
           );
          },
        ),

        // 📅 حجز عيادة
        SpeedDialChild(
          child: const Icon(Icons.calendar_month, color: Colors.white),
          backgroundColor: Colors.purple,
          label: 'حجز عيادة',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.purple),
          labelBackgroundColor: Colors.white,
          onTap: () {
            // ✅ تأكد إن BookAppointmentScreen معمولها import فوق
            // Navigator.push(context, MaterialPageRoute(builder: (c) => const BookAppointmentScreen()));
          },
        ),
      ],
    );
  }
}
