import 'package:flutter/material.dart';
import '../template/section_template.dart'; // استدعاء القالب الذكي المحدث

class VitaminsScreen extends StatelessWidget {
  final bool isAdmin;
  const VitaminsScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return PharmacySectionTemplate(
      title: "الفيتامينات والمكملات",
      categoryId: "vitamins",
      isAdmin: isAdmin, // 👈 تم تمرير القيمة هنا
      primaryColor: Colors.orange,
      sectionIcon: Icons.wb_sunny_rounded,
    );
  }
}