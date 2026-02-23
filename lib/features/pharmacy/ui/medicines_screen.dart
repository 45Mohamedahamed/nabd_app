import 'package:flutter/material.dart';
import '../template/section_template.dart'; // استدعاء القالب الذكي المحدث

class MedicinesScreen extends StatelessWidget {
  final bool isAdmin;
  const MedicinesScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return PharmacySectionTemplate(
      title: "الأدوية والعلاجات",
      categoryId: "medicines",
      isAdmin: isAdmin, // 👈 تم تمرير القيمة هنا
      primaryColor: const Color(0xFF1E88E5),
      sectionIcon: Icons.medication_liquid_rounded,
    );
  }
}