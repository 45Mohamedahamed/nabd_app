import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart'; // إضافة حركات جمالية

// 👇 استدعاء طبقة البيانات (Data Layer)
import '../../notification_services/repositories/notification_repository.dart';
import '../../notification_services/model/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  final Color mainColor = const Color(0xFF005DA3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("الإشعارات", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              // 🗑️ ميزة إضافية: مسح كل الإشعارات
              NotificationRepository().clearAll();
            }, 
            child: Text("مسح الكل", style: TextStyle(color: Colors.redAccent, fontSize: 12.sp)),
          )
        ],
      ),
      
      // 🔄 القلب النابض للشاشة: ValueListenableBuilder
      // هذا هو البديل المحلي للـ StreamBuilder الخاص بالفايربيز
      body: ValueListenableBuilder<List<NotificationModel>>(
        valueListenable: NotificationRepository().notifications,
        builder: (context, notifs, child) {
          
          // 1. حالة القائمة الفارغة
          if (notifs.isEmpty) return _buildEmptyState();

          // 2. عرض القائمة
          return ListView.separated(
            padding: EdgeInsets.all(20.w),
            itemCount: notifs.length,
            separatorBuilder: (c, i) => SizedBox(height: 15.h),
            itemBuilder: (context, index) {
              final notification = notifs[index];
              
              // إضافة انيميشن عند ظهور الإشعار
              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: Dismissible( // ميزة السحب للحذف
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    // حذف من المخزن (Logic needed in Repo)
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.w),
                    decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(15.r)),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  child: _buildNotificationItem(context, notification),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notif) {
    IconData icon;
    Color color;
    bool hasAction = false;

    // 🎨 تحديد المظهر بناءً على نوع الإشعار (Data-Driven UI)
    switch (notif.type) {
      case 'medication_action':
        icon = Icons.medication_liquid;
        color = Colors.orange;
        hasAction = true;
        break;
      case 'followup_action':
        icon = Icons.assignment_ind;
        color = mainColor;
        hasAction = true;
        break;
      case 'alert':
        icon = Icons.warning_rounded;
        color = Colors.red;
        break;
      default: // info
        icon = Icons.notifications_active_rounded;
        color = Colors.blueGrey;
    }

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : color.withOpacity(0.04), // تمييز غير المقروء
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: notif.isRead ? Colors.grey.shade200 : color.withOpacity(0.3)),
        boxShadow: [
          if (!notif.isRead)
            BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الأيقونة الملونة
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(width: 15.w),
              
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(notif.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
                        Text(notif.time, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(notif.body, style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp, height: 1.4)),
                  ],
                ),
              ),
              
              // نقطة التنبيه (Unread Dot)
              if (!notif.isRead)
                Container(
                  margin: EdgeInsets.only(left: 8.w, top: 5.h),
                  width: 8.w, height: 8.w,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                )
            ],
          ),

          // 👇 الأزرار التفاعلية (Actions Area)
          if (hasAction) ...[
            SizedBox(height: 15.h),
            Divider(color: Colors.grey.shade100),
            SizedBox(height: 5.h),
            
            if (notif.type == 'medication_action')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () { /* منطق تخطي الجرعة */ },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                      ),
                      child: Text("تخطي", style: TextStyle(color: Colors.red.shade400)),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmationDialog(context, "تم تسجيل الجرعة بنجاح ✅"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                      ),
                      child: const Text("تم أخذ الدواء", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else if (notif.type == 'followup_action')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showFollowUpDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))
                  ),
                  icon: const Icon(Icons.assignment_turned_in, color: Colors.white, size: 16),
                  label: const Text("بدء المتابعة الآن", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
          ]
        ],
      ),
    );
  }

  // --- Dialogs (كما هي لضمان التفاعل) ---

  void _showConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 15.h),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showFollowUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("متابعة الحالة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("كيف هو مستوى الألم اليوم؟"),
            SizedBox(height: 10.h),
            Slider(value: 0.5, onChanged: (v){}, activeColor: mainColor),
            SizedBox(height: 10.h),
            TextField(
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "أي ملاحظات أخرى؟",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmationDialog(context, "شكراً لك، تم إرسال الرد للطبيب.");
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            child: const Text("إرسال التقرير", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(Icons.notifications_off_outlined, size: 60.sp, color: Colors.grey.shade400),
            ),
            SizedBox(height: 20.h),
            Text("لا توجد إشعارات جديدة", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            SizedBox(height: 5.h),
            Text("سنخبرك بمواعيد الدواء والمتابعات هنا", style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}