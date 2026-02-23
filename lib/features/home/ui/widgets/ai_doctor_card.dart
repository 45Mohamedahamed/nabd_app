import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 👇 تأكد من استدعاء شاشة الرفع (العمود الفقري)
import '../../../upload/ui/upload_documents_screen.dart'; 
// لو الملف ده مش موجود عندك، غير المسار أو استخدم Container فاضي مؤقتاً

class AiDoctorCard extends StatelessWidget {
  const AiDoctorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: GestureDetector(
        onTap: () {
          // الانتقال لمركز الرفع الذكي
           Navigator.push(context, MaterialPageRoute(builder: (c) => SmartUploadScreen(patientId:FirebaseAuth.instance.currentUser?.uid ?? '')));
        },
        child: Container(
          width: double.infinity,
          height: 160.h,
          margin: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2575FC).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30, top: -30,
                child: CircleAvatar(radius: 60.r, backgroundColor: Colors.white.withOpacity(0.1)),
              ),
              Positioned(
                left: -20, bottom: -20,
                child: CircleAvatar(radius: 40.r, backgroundColor: Colors.white.withOpacity(0.1)),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 16.sp),
                                SizedBox(width: 5.w),
                                Text("AI Powered", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "الفحص الذكي الشامل",
                            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "ارفع تحاليلك ودع الذكاء الاصطناعي يحللها لك.",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: Icon(Icons.document_scanner_rounded, color: Colors.white, size: 40.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}