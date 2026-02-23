import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text("هذا القسم قيد التطوير 🔨", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("نعمل بجد لإطلاق هذه الخدمة قريباً", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}