import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';

class PharmacyOrdersScreen extends StatelessWidget {
  const PharmacyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("طلبات الأدوية الواردة", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [_buildOrderCounter()],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // جلب الطلبات مرتبة حسب الأحدث
        stream: FirebaseFirestore.instance
            .collection('pharmacy_orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final isUrgent = order['status'] == 'urgent';

              return isUrgent 
                ? FadeInLeft(child: _buildUrgentOrderCard(context, orders[index].id, order))
                : _buildNormalOrderCard(context, orders[index].id, order);
            },
          );
        },
      ),
    );
  }

  // 🚨 كارت الطلب العاجل (بروتوكول الطوارئ)
  Widget _buildUrgentOrderCard(BuildContext context, String docId, Map<String, dynamic> data) {
    return Pulse(
      infinite: true,
      child: Card(
        color: const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.emergency, color: Colors.white)),
          title: Text("🚨 طوارئ: ${data['babyName']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          subtitle: Text("المطلوب: ${data['items'][0]['name']} + ${data['items'][1]['name']}"),
          trailing: ElevatedButton(
            onPressed: () => _markAsPrepared(docId),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("تم التحضير", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // 📦 كارت الطلب العادي
  Widget _buildNormalOrderCard(BuildContext context, String docId, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.blue),
        title: Text(data['babyName'] ?? "طلب عام"),
        subtitle: const Text("طلب أدوية دورية"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  // تحديث حالة الطلب في الفايربيز
  void _markAsPrepared(String id) {
    FirebaseFirestore.instance.collection('pharmacy_orders').doc(id).update({'status': 'prepared'});
  }

  Widget _buildOrderCounter() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pharmacy_orders').where('status', isEqualTo: 'urgent').snapshots(),
      builder: (context, snap) {
        int count = snap.hasData ? snap.data!.docs.length : 0;
        return Padding(
          padding: EdgeInsets.only(right: 15.w),
          child: Badge(label: Text("$count"), child: const Icon(Icons.notifications_active)),
        );
      }
    );
  }
}