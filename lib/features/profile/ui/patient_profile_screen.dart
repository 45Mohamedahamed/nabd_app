import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';

// 👇 استدعاء الصفحات الفرعية
import 'edit_profile_screen.dart';
import 'medical_history_screen.dart';
import 'insurance_card_screen.dart';
import 'language_screen.dart';
import 'notification_settings_screen.dart';
import '../../auth/ui/login_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF005DA3);
    final user = FirebaseAuth.instance.currentUser;

    // 🔑 QR Data: يحتوي على ID المريض فقط للحفاظ على الخصوصية
    // الطبيب سيمسحه ويجلب البيانات من عنده
    final String myQrData = "PAT:${user?.uid ?? 'guest'}";

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("ملفي الشخصي", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen())),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 1. كارت البيانات (مربوط بـ Firestore)
            _buildLiveProfileHeader(mainColor, user),

            SizedBox(height: 25.h),

            // 2. الهوية الطبية (QR Code) مع أنيميشن
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: _buildMedicalIdCard(context, myQrData, mainColor),
            ),

            SizedBox(height: 30.h),

            // 3. القائمة
            _buildSectionHeader("إعدادات الحساب"),
            _buildSettingsItem(
              Icons.person_outline,
              "تعديل البيانات الشخصية",
              () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen())),
            ),
            _buildSettingsItem(
              Icons.history,
              "السجل الطبي السابق",
              () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MedicalHistoryScreen())),
            ),
            _buildSettingsItem(
              Icons.card_membership,
              "بطاقة التأمين",
              () => Navigator.push(context, MaterialPageRoute(builder: (c) => const InsuranceCardScreen())),
            ),

            SizedBox(height: 20.h),

            _buildSectionHeader("إعدادات التطبيق"),
            _buildSettingsItem(
              Icons.language,
              "اللغة / Language",
              () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LanguageScreen())),
            ),
            _buildSettingsItem(
              Icons.notifications_outlined,
              "الإشعارات",
              () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationSettingsScreen())),
            ),

            SizedBox(height: 30.h),

            // زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🛠️ Widgets ---

  // 📡 هيدر البروفايل المتصل بـ Firebase
  Widget _buildLiveProfileHeader(Color color, User? user) {
    if (user == null) return const Text("يرجى تسجيل الدخول");

    // نستخدم StreamBuilder للاستماع لأي تغيير في البيانات (مثل تغيير الاسم أو الصورة)
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String name = user.displayName ?? "مستخدم جديد";
        String email = user.email ?? "";
        String? photoUrl = user.photoURL;

        // لو البيانات موجودة في Firestore، نستخدمها (لأنها قد تكون أحدث)
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? name;
          // photoUrl = data['photoUrl'] ?? photoUrl; // لو خزنا الصورة في Firestore
        }

        return Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(4.w), // إطار أبيض
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null ? Icon(Icons.person, size: 50.sp, color: Colors.grey) : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    // عند الضغط، نفتح صفحة التعديل مباشرة
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EditProfileScreen())),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: Icon(Icons.edit, size: 14.sp, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12.h),
            Text(name, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(email, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          ],
        );
      },
    );
  }

  Widget _buildMedicalIdCard(BuildContext context, String qrData, Color color) {
    return GestureDetector(
      onTap: () => _showMedicalIDDialog(context, qrData, color),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFFF0F8FF)], 
            begin: Alignment.topLeft, end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: const Color(0xFF005DA3).withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
          border: Border.all(color: const Color(0xFF005DA3).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 60.0,
                gapless: false,
                foregroundColor: color,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("بطاقتي الطبية", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color)),
                  SizedBox(height: 5.h),
                  Text("امسح الكود للوصول السريع لسجلك الطبي عند الطبيب", style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  // ... (باقي الـ Widgets كما هي في كودك الممتاز)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, right: 5.w),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.grey.shade50, blurRadius: 5)],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: const Color(0xFF005DA3).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF005DA3), size: 20.sp),
        ),
        title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الخروج"),
        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              // 🚪 تسجيل الخروج الفعلي من فايربيز
              await FirebaseAuth.instance.signOut();
              
              if(!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (c) => const LoginScreen()), (route) => false
              );
            },
            child: const Text("خروج", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMedicalIDDialog(BuildContext context, String qrData, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("QR Code الطبي", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 5.h),
              Text("رقم الملف: ${qrData.split(':')[1]}", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              SizedBox(height: 20.h),
              SizedBox(
                height: 200.h,
                width: 200.w,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: color),
                  eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle, color: color),
                ),
              ),
              SizedBox(height: 20.h),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("إغلاق")),
            ],
          ),
        ),
      ),
    );
  }
}