import 'package:flutter/material.dart';
import '../../features/appointmen/medical_services_screen.dart'; // تأكد إن المسار ده صح عندك

class AiSymptomScreen extends StatelessWidget {
  const AiSymptomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الفحص بالذكاء الاصطناعي")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monitor_heart, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("شاشة الفحص الذكي", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // الزرار اللي كان عامل مشكلة، دلوقتي بيودي صح
                Navigator.push(context, MaterialPageRoute(builder: (c) => const MedicalServicesScreen()));
              },
              child: const Text("حجز موعد الآن"),
            ),
          ],
        ),
      ),
    );
  }
}