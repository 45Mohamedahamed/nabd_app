import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ
import '../../Medical Encyclopedia/model/medical_models.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final DiseaseModel disease;
  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // زر عائم للمشاركة (إضافة جمالية)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF005DA3),
        icon: const Icon(Icons.share_rounded, color: Colors.white),
        label: const Text("مشاركة المعلومات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. الهيدر المتحرك (صورة وانيميشن)
          _buildSliverAppBar(context),

          // 2. المحتوى
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // المعلومات الأساسية (تصنيف وتاريخ)
                  FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: _buildHeaderInfo(),
                  ),
                  
                  SizedBox(height: 20.h),

                  // النبذة المختصرة (Highlight)
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildBriefCard(),
                  ),

                  SizedBox(height: 25.h),

                  // نظرة عامة
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSection("نظرة عامة", disease.overview, Icons.menu_book_rounded),
                  ),

                  // الأعراض (Grid Style)
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildListSection("الأعراض الشائعة", disease.symptoms, Icons.sick_rounded, Colors.orange),
                  ),

                  // عوامل الخطر
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildListSection("عوامل الخطر", disease.riskFactors, Icons.analytics_outlined, Colors.red),
                  ),

                  // قسم الوقاية (تصميم مميز)
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: _buildPreventionSection(),
                  ),

                  // العلاج (Timeline Style)
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildTreatmentSection(),
                  ),

                  SizedBox(height: 30.h),

                  // المصدر وإخلاء المسؤولية
                  _buildFooter(),
                  
                  SizedBox(height: 80.h), // مسافة عشان الزر العائم
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets Building Blocks ---

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.h, // ارتفاع أكبر
      pinned: true,
      backgroundColor: const Color(0xFF005DA3),
      leading: IconButton(
        icon: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.arrow_back, color: Colors.white)),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.bookmark_border, color: Colors.white)),
          onPressed: () {},
        ),
        SizedBox(width: 10.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة (Hero Animation)
            Hero(
              tag: disease.id, // ربط الانيميشن بالقائمة
              child: disease.imageUrl.isNotEmpty && disease.imageUrl.startsWith('http')
                  ? Image.network(disease.imageUrl, fit: BoxFit.cover)
                  : Container(color: Colors.blueGrey, child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white)),
            ),
            // تدرج لوني لظهور النص
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            // عنوان المرض فوق الصورة
            Positioned(
              bottom: 20.h,
              right: 20.w,
              left: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(5.r)),
                    child: Text(disease.category, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    disease.name,
                    style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.update, size: 16.sp, color: Colors.grey),
            SizedBox(width: 5.w),
            Text("آخر تحديث: ${DateFormat('yyyy-MM-dd').format(disease.lastUpdated)}", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20.r)),
          child: Row(
            children: [
              Icon(Icons.verified, size: 16.sp, color: const Color(0xFF005DA3)),
              SizedBox(width: 5.w),
              Text("موثوق", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF005DA3), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBriefCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border(right: BorderSide(color: const Color(0xFF005DA3), width: 4.w)),
      ),
      child: Text(
        disease.brief,
        style: TextStyle(fontSize: 14.sp, color: Colors.grey[800], fontStyle: FontStyle.italic, height: 1.5),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFF005DA3), size: 22.sp), SizedBox(width: 10.w), Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87))]),
          SizedBox(height: 10.h),
          Text(content, style: TextStyle(fontSize: 15.sp, height: 1.6, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 22.sp), SizedBox(width: 10.w), Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87))]),
          SizedBox(height: 15.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: items.map((item) => Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8.sp, color: color),
                  SizedBox(width: 8.w),
                  Flexible(child: Text(item, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500))),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreventionSection() {
    if (disease.prevention.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.shield_rounded, color: Colors.green, size: 28.sp), SizedBox(width: 10.w), Text("طرق الوقاية", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green[800]))]),
          SizedBox(height: 15.h),
          ...disease.prevention.map((e) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 18.sp, color: Colors.green),
                SizedBox(width: 10.w),
                Expanded(child: Text(e, style: TextStyle(color: Colors.green[900], fontSize: 14.sp, fontWeight: FontWeight.w500))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTreatmentSection() {
    if (disease.treatments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.medication_rounded, color: Colors.blue, size: 24.sp), SizedBox(width: 10.w), Text("بروتوكول العلاج", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold))]),
          SizedBox(height: 15.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: disease.treatments.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                      child: Text("${index + 1}", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(child: Text(disease.treatments[index], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10.r)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.source, size: 16.sp, color: Colors.grey),
              SizedBox(width: 5.w),
              Text("المصدر العلمي: ${disease.sourceName}", style: TextStyle(fontSize: 12.sp, color: Colors.grey[700], fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 10.w),
              Expanded(child: Text("هذه المعلومات للأغراض التعليمية. استشر طبيبك دائماً.", style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]))),
            ],
          ),
        ],
      ),
    );
  }
}