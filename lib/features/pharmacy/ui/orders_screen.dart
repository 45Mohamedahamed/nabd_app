import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../service/pharmacy_service.dart';
import '../model/order_model.dart';
import 'package:intl/intl.dart'; // ستحتاج لإضافة intl في pubspec للوقت

class OrdersScreen extends StatelessWidget {
 const OrdersScreen({super.key, required this.isAdmin});
  final bool isAdmin;
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("طلباتي"), centerTitle: true),
      body: StreamBuilder<List<OrderModel>>(
        stream: PharmacyService().getMyOrders("user_123"), // نستخدم نفس الـ ID المؤقت
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد طلبات سابقة"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: EdgeInsets.all(15.w),
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return Card(
                margin: EdgeInsets.only(bottom: 15.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("طلب #${order.orderId.substring(0, 8)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusBadge(order.status),
                        ],
                      ),
                      const Divider(),
                      Text("التاريخ: ${DateFormat('yyyy-MM-dd – kk:mm').format(order.createdAt)}"),
                      Text("عدد الأصناف: ${order.items.length}"),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("الإجمالي:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${order.totalAmount} ج.م", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'pending': text = "قيد الانتظار"; color = Colors.orange; break;
      case 'shipping': text = "جاري التوصيل"; color = Colors.blue; break;
      case 'delivered': text = "تم التسليم"; color = Colors.green; break;
      default: text = status; color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.sp)),
    );
  }
}