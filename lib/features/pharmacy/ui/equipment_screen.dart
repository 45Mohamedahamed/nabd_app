import 'package:flutter/material.dart';
import '../template/section_template.dart'; // استدعاء القالب الذكي المحدث

class EquipmentScreen extends StatelessWidget {
  final bool isAdmin;
  const EquipmentScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return PharmacySectionTemplate(
      title: "الأجهزة والمعدات الطبية",
      categoryId: "equipment",
      isAdmin: isAdmin, // 👈 تم تمرير القيمة هنا
      primaryColor: Colors.teal,
      sectionIcon: Icons.monitor_heart_outlined,
    );
  }
}