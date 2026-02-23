import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

// 👇 تأكد من صحة هذه المسارات في مشروعك
import '../model/wellness_model.dart';
import 'add_wellness_content_screen.dart';
import '../../Medical Encyclopedia/Service/medical_content_service.dart';


class AwarenessScreen extends StatefulWidget {
  const AwarenessScreen({super.key});

  @override
  State<AwarenessScreen> createState() => _AwarenessScreenState();
}

class _AwarenessScreenState extends State<AwarenessScreen> {
  // 🔐 محاكاة صلاحية الأدمن (يمكن ربطها لاحقاً بـ FirebaseAuth)
  bool isAdmin = true;
  
  // 🏷️ متغير الفلترة النشط
  String _selectedCategory = "الكل"; 
  
  // 📡 كائن السيرفيس للاتصال بالفايربيز
  final MedicalContentService _contentService = MedicalContentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      
      // 🛡️ زر الإضافة (للأدمن فقط)
      floatingActionButton: isAdmin
          ? FadeInUp(
              child: FloatingActionButton.extended(
                onPressed: () async {
                  // فتح شاشة الإضافة (الشاشة نفسها ستقوم بالرفع للفايربيز)
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const AddWellnessContentScreen()),
                  );
                  // لا نحتاج هنا لـ setState لأن الـ StreamBuilder سيكتشف الإضافة تلقائياً ويحدث الشاشة! 🪄
                },
                backgroundColor: Colors.teal,
                icon: const Icon(Icons.post_add, color: Colors.white),
                label: const Text("نشر محتوى", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : null,

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. الهيدر (SliverAppBar) المدمج والجميل
          _buildSliverAppBar(), 

          // 2. المحتوى التفاعلي (مربوط بالفايربيز)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // 🏷️ شريط التصنيفات (Filters)
                  FadeInDown(child: _buildCategories()),
                  SizedBox(height: 25.h),

                  // 📡 الـ StreamBuilder لقراءة البيانات الحية من الفايربيز
                  StreamBuilder<List<WellnessItem>>(
                    stream: _contentService.getWellnessStream(),
                    builder: (context, snapshot) {
                      
                      // ⏳ حالة التحميل
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            children: [
                              SizedBox(height: 50.h),
                              const CircularProgressIndicator(color: Colors.teal),
                              SizedBox(height: 10.h),
                              Text("جاري جلب المحتوى الصحي...", style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          ),
                        );
                      }

                      // 📭 حالة الخطأ
                      if (snapshot.hasError) {
                        return Center(child: Text("حدث خطأ في جلب البيانات: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                      }

                      // 📭 حالة عدم وجود بيانات تماماً
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState("لا توجد مقالات أو نصائح حالياً في الواحة.");
                      }

                      final allContent = snapshot.data!;

                      // 🧠 الفلترة المحلية حسب التصنيف المختار
                      final filteredContent = _selectedCategory == "الكل" 
                          ? allContent 
                          : allContent.where((e) => e.category == _selectedCategory).toList();

                      // 📭 حالة عدم وجود بيانات في القسم المختار
                      if (filteredContent.isEmpty) {
                        return _buildEmptyState("لا يوجد محتوى صحي في قسم '$_selectedCategory' بعد.");
                      }

                      // ✂️ فصل النصائح عن المقالات لتنظيم العرض
                      final tips = filteredContent.where((e) => e.type == ContentType.tip).toList();
                      final articles = filteredContent.where((e) => e.type == ContentType.article).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          // 💡 عرض "نصيحة اليوم" (نأخذ أحدث نصيحة فقط)
                          if (tips.isNotEmpty) ...[
                            _buildSectionHeader("نصيحة اليوم", Icons.lightbulb_outline),
                            SizedBox(height: 15.h),
                            FadeInLeft(
                              duration: const Duration(milliseconds: 500),
                              child: _buildDailyTipCard(tips.first), 
                            ),
                            SizedBox(height: 35.h),
                          ],

                          // 📰 عرض قائمة المقالات (تصميم كروت)
                          if (articles.isNotEmpty) ...[
                            _buildSectionHeader("مقالات حديثة", Icons.article_outlined),
                            SizedBox(height: 15.h),
                            
                            // استخدام Spread Operator `...` لدمج الكروت في الـ Column
                            ...articles.asMap().entries.map((entry) {
                              int index = entry.key;
                              WellnessItem article = entry.value;
                              
                              return FadeInUp(
                                // تأخير متدرج لظهور الكروت بشكل جمالي
                                delay: Duration(milliseconds: index * 100), 
                                child: _buildArticleCard(article),
                              );
                            }),
                          ],
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 80.h), // مسافة سفلية لعدم تغطية الزر العائم
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎨 Widgets & Components
  // ---------------------------------------------------------------------------

  // 1. الهيدر (Sliver App Bar)
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140.h,
      pinned: true,
      backgroundColor: Colors.teal,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text("واحة الصحة", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00695C), Color(0xFF4DB6AC)], // تدرج أخضر/تيل مريح للعين
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // أيقونة خلفية شفافة للمسة جمالية
              Positioned(
                right: -20.w, 
                top: -10.h, 
                child: Icon(Icons.spa_rounded, size: 140.sp, color: Colors.white.withOpacity(0.08))
              ),
              Positioned(
                left: 20.w, 
                bottom: 20.h, 
                child: Icon(Icons.self_improvement_rounded, size: 60.sp, color: Colors.white.withOpacity(0.1))
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. شريط التصنيفات (تفاعلي)
  Widget _buildCategories() {
    // قائمة الأقسام (يجب أن تتطابق مع الموجودة في شاشة الإضافة)
    List<String> cats = ["الكل", "تغذية", "صحة نفسية", "لياقة", "عادات صحية", "إسعافات"];
    
    return SizedBox(
      height: 45.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == cats[index];
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cats[index]), // 🔄 تحديث الفلتر
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(left: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                boxShadow: isSelected ? [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Text(
                cats[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. عنوان القسم
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.teal, size: 20.sp)
        ),
        SizedBox(width: 10.w),
        Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  // 4. كارت نصيحة اليوم (يأخذ بياناته من الموديل)
  Widget _buildDailyTipCard(WellnessItem tip) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF80CBC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8.r)),
                child: Text(tip.category, style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
              ),
              Icon(Icons.format_quote_rounded, color: Colors.white.withOpacity(0.4), size: 35.sp),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            tip.content, // محتوى النصيحة الفعلي
            style: TextStyle(color: Colors.white, fontSize: 16.sp, height: 1.6, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("- ${tip.author}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // 5. كارت المقال
  Widget _buildArticleCard(WellnessItem article) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.r),
        onTap: () {
          // يمكن هنا فتح شاشة تفاصيل المقال (ArticleDetailScreen) مستقبلاً
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الغلاف (إذا وجدت، وإلا نعرض أيقونة ملونة)
            Container(
              height: 130.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                image: article.imageUrl != null && article.imageUrl!.isNotEmpty
                    ? DecorationImage(image: NetworkImage(article.imageUrl!), fit: BoxFit.cover) 
                    : null,
              ),
              child: article.imageUrl == null || article.imageUrl!.isEmpty
                  ? Center(child: Icon(Icons.article_rounded, size: 50.sp, color: Colors.teal.withOpacity(0.3))) 
                  : null,
            ),
            
            // محتوى الكارت
            Padding(
              padding: EdgeInsets.all(15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(article.category, style: TextStyle(color: Colors.teal, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      Text(DateFormat('d MMM yyyy').format(article.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    article.title, 
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    article.content, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, 
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600, height: 1.4)
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      CircleAvatar(radius: 12.r, backgroundColor: Colors.grey.shade200, child: Icon(Icons.person, size: 14.sp, color: Colors.grey.shade600)),
                      SizedBox(width: 8.w),
                      Text(article.author, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text("اقرأ المزيد", style: TextStyle(fontSize: 12.sp, color: Colors.teal, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward_ios, size: 10.sp, color: Colors.teal),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. حالة فارغة مخصصة
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          Icon(Icons.spa_outlined, size: 80.sp, color: Colors.grey.shade300),
          SizedBox(height: 15.h),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}