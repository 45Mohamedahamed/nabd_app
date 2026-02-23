import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InsuranceCardScreen extends StatelessWidget {
  const InsuranceCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("بطاقة التأمين"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      // 📡 جلب بيانات المريض من الفايربيز
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          
          // 🧠 استخراج التأمين أو وضع قيم افتراضية
          final insurance = userData?['insurance'] as Map<String, dynamic>? ?? {
            'number': '---- ---- ---- ----',
            'provider': 'غير مسجل',
            'expDate': '--/--',
            'surgeryCover': '0%',
            'medsCover': '0%',
            'dental': 'غير مغطى',
            'isActive': false
          };

          bool isActive = insurance['isActive'] ?? false;

          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // تصميم الكارت
                Container(
                  height: 200.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // لون رمادي لو التأمين غير مفعل، أزرق لو مفعل
                      colors: isActive ? [const Color(0xFF005DA3), const Color(0xFF003366)] : [Colors.grey.shade600, Colors.grey.shade800],
                      begin: Alignment.topLeft, end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [BoxShadow(color: (isActive ? Colors.blue : Colors.grey).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(insurance['provider'], style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                          Icon(Icons.shield, color: Colors.white.withOpacity(isActive ? 0.8 : 0.3), size: 30.sp),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insurance['number'], style: TextStyle(color: Colors.white, fontSize: 22.sp, letterSpacing: 2, fontFamily: 'Courier')),
                          SizedBox(height: 15.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("MEMBER NAME", style: TextStyle(color: Colors.white70, fontSize: 10.sp)), Text(userData?['name']?.toUpperCase() ?? "UNKNOWN", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("EXP DATE", style: TextStyle(color: Colors.white70, fontSize: 10.sp)), Text(insurance['expDate'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                
                // تفاصيل التغطية الديناميكية
                ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: const Text("تغطية العمليات الجراحية"), trailing: Text(insurance['surgeryCover'], style: const TextStyle(fontWeight: FontWeight.bold))),
                ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: const Text("تغطية الأدوية"), trailing: Text(insurance['medsCover'], style: const TextStyle(fontWeight: FontWeight.bold))),
                ListTile(leading: Icon(insurance['dental'] == 'مغطى' ? Icons.check_circle : Icons.cancel, color: insurance['dental'] == 'مغطى' ? Colors.green : Colors.red), title: const Text("تجميل الأسنان"), trailing: Text(insurance['dental'], style: TextStyle(color: insurance['dental'] == 'مغطى' ? Colors.green : Colors.red))),
              ],
            ),
          );
        },
      ),
    );
  }
}