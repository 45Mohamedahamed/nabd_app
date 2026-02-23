import 'package:flutter/material.dart';
import '../../pharmacy/template/section_template.dart'; // استدعاء القالب الذكي المحدث

class CareScreen extends StatelessWidget {
  final bool isAdmin;
  const CareScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return PharmacySectionTemplate(
      title: "العناية الشخصية والجمال",
      categoryId: "care",
      isAdmin: isAdmin, // 👈 تم تمرير القيمة هنا
      primaryColor: const Color(0xFFE91E63),
      sectionIcon: Icons.face_retouching_natural,
    );
  }
}