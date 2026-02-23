import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

// 👇 تأكد من هذه المسارات حسب مشروعك
import 'encyclopedia_screen.dart';
import '../../Health & Wellness/ui/awareness_screen.dart';
import '../service/medical_content_service.dart';
import '../model/medical_models.dart';
import '../../Health & Wellness/model/wellness_model.dart'; // موديل التوعية
class MedicalHubScreen extends StatefulWidget {
  const MedicalHubScreen({super.key});

  @override
  State<MedicalHubScreen> createState() => _MedicalHubScreenState();
}

class _MedicalHubScreenState extends State<MedicalHubScreen> {
  // 🔐 محاكاة صلاحية الأدمن (يمكن ربطها ببيانات المستخدم لاحقاً)
  bool isAdmin = true;

  // 📡 كائن السيرفيس لقراءة المحتوى
  final MedicalContentService _contentService = MedicalContentService();

  // 💡 هذه الدالة يمكن ربطها بشاشة AddWellnessContentScreen لاحقاً
  void _openAddArticleScreen() {
    // Navigator.push(context, MaterialPageRoute(builder: (c) => const AddWellnessContentScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("سيتم فتح شاشة إضافة المحتوى..."),
        backgroundColor: Color(0xFF005DA3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // 🛡️ زر الإضافة (للأدمن فقط)
      floatingActionButton: isAdmin
          ? FadeInUp(
              child: FloatingActionButton.extended(
                onPressed: _openAddArticleScreen,
                backgroundColor: const Color(0xFF005DA3),
                icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
                label: const Text("نشر تحديث", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : null,

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. الهيدر العملاق (Sliver App Bar)
          _buildSliverAppBar(),

          // 2. محتوى الصفحة
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // 🔎 البحث والفلاتر
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: _buildSearchSection()
                  ),

                  SizedBox(height: 25.h),

                  // 💡 كارت "معلومة اليوم" (يمكن ربطها بالفايربيز أيضاً بنفس طريقة المقالات)
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: _buildDailyTipCard()
                  ),

                  SizedBox(height: 30.h),

                  // 📂 الأقسام الرئيسية (الموسوعة & التوعية)
                  _buildSectionHeader("المراجع الطبية", "تصفح قاعدة البيانات الشاملة", () {}),
                  SizedBox(height: 15.h),

                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildGiantCard(
                      context,
                      title: "الموسوعة الطبية",
                      subtitle: "الأمراض، الأعراض، التشخيص، وبروتوكولات العلاج.",
                      imageIcon: Icons.menu_book_rounded,
                      color1: const Color(0xFF005DA3),
                      color2: const Color(0xFF0091EA),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EncyclopediaScreen())),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildGiantCard(
                      context,
                      title: "واحة الصحة & الوقاية",
                      subtitle: "نمط الحياة، التغذية، الصحة النفسية، والإسعافات.",
                      imageIcon: Icons.self_improvement_rounded,
                      color1: const Color(0xFF00695C),
                      color2: const Color(0xFF4DB6AC),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AwarenessScreen())),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // 🛠️ أدوات الصحة الذكية
                  _buildSectionHeader("أدوات ذكية", "خدمات سريعة لصحتك", () {}),
                  SizedBox(height: 15.h),
                  _buildSmartToolsGrid(),

                  SizedBox(height: 30.h),

                  // 📰 مقالات مختارة (✨ مربوطة بالفايربيز الآن ✨)
                  _buildSectionHeader(
                    "تحديثات طبية", 
                    "أحدث المقالات والأخبار", 
                    () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AwarenessScreen())) // يذهب لواحة الصحة لقراءة الكل
                  ),
                  SizedBox(height: 15.h),
                  _buildFeaturedArticlesList(),

                  SizedBox(height: 80.h), // مسافة للزر العائم
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

  // 1. الهيدر المتحرك
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160.h,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF005DA3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // خلفية متدرجة
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF003366), Color(0xFF005DA3)],
                ),
              ),
            ),
            // دوائر زخرفية شفافة
            Positioned(top: -50, right: -50, child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05))),
            Positioned(bottom: -30, left: 20, child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.05))),

            // المحتوى النصي للهيدر
            Positioned(
              bottom: 30.h,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("المركز الطبي", style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8.w),
                      Icon(Icons.verified, color: Colors.lightBlueAccent, size: 20.sp),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text("رعايتك الصحية تبدأ بالمعرفة", style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. قسم البحث والفلاتر
  Widget _buildSearchSection() {
    return Column(
      children: [
        // شريط البحث
        Container(
          height: 55.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "عن ماذا تبحث اليوم؟ (مثال: سكري، صداع)",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF005DA3)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        // فلاتر سريعة (Tags)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildQuickTag("فحص الأعراض", Icons.accessibility_new_rounded, true),
              _buildQuickTag("دليل الأدوية", Icons.medication_rounded, false),
              _buildQuickTag("الأطباء", Icons.people_alt_rounded, false),
              _buildQuickTag("المستشفيات", Icons.local_hospital_rounded, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTag(String label, IconData icon, bool isActive) {
    return Container(
      margin: EdgeInsets.only(left: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF005DA3) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isActive ? Colors.transparent : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: isActive ? Colors.white : Colors.grey[600]),
          SizedBox(width: 5.w),
          Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 12.sp)),
        ],
      ),
    );
  }

  // 3. كارت معلومة اليوم (ثابت حالياً، ويمكن ربطه بالفايربيز بسهولة)
  Widget _buildDailyTipCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFB74D)]),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 30),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("معلومة تهمك", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 5.h),
                Text(
                  "شرب الماء قبل الوجبات بـ 30 دقيقة يساعد في تحسين الهضم وإنقاص الوزن.",
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. الكروت العملاقة
  Widget _buildGiantCard(BuildContext context, {required String title, required String subtitle, required IconData imageIcon, required Color color1, required Color color2, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        height: 140.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(colors: [color1, color2], begin: Alignment.centerLeft, end: Alignment.centerRight),
          boxShadow: [BoxShadow(color: color1.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            Positioned(left: -20, bottom: -20, child: Icon(imageIcon, size: 130.sp, color: Colors.white.withOpacity(0.1))),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp, height: 1.4)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. شبكة الأدوات
  Widget _buildSmartToolsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 15.w,
      mainAxisSpacing: 15.h,
      childAspectRatio: 0.9,
      children: [
        _buildToolItem("مؤشر الكتلة", Icons.monitor_weight_rounded, Colors.purple),
        _buildToolItem("تذكير الدواء", Icons.alarm_on_rounded, Colors.teal),
        _buildToolItem("الإسعافات", Icons.medical_services_rounded, Colors.redAccent),
        _buildToolItem("تحليل الأعراض", Icons.analytics_rounded, Colors.indigo),
        _buildToolItem("التطعيمات", Icons.vaccines_rounded, Colors.orange),
        _buildToolItem("الفيتامينات", Icons.wb_sunny_rounded, Colors.amber),
      ],
    );
  }

  Widget _buildToolItem(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 10.h),
          Text(title, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        ],
      ),
    );
  }

  // 6. 🌟 قائمة المقالات المربوطة بالفايربيز 🌟
  Widget _buildFeaturedArticlesList() {
    return SizedBox(
      height: 140.h,
      child: StreamBuilder<List<WellnessItem>>(
        stream: _contentService.getFeaturedArticlesStream(), // 📡 قراءة من السيرفر
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF005DA3)));
          }

          if (snapshot.hasError) {
             return Center(child: Text("حدث خطأ في جلب التحديثات", style: TextStyle(color: Colors.red, fontSize: 12.sp)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("لا توجد تحديثات طبية حالياً", style: TextStyle(color: Colors.grey.shade500)));
          }

          final articles = snapshot.data!;
          List<Color> tagsColors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              Color currentTagColor = tagsColors[index % tagsColors.length]; // لون مختلف لكل كارت

              return FadeInRight(
                delay: Duration(milliseconds: index * 100),
                child: _buildArticleCard(article, currentTagColor),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(WellnessItem article, Color tagColor) {
    return InkWell(
      onTap: () {
        // يمكنك لاحقاً إضافة Navigation لفتح تفاصيل المقال
      },
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        width: 200.w,
        margin: EdgeInsets.only(left: 15.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  image: article.imageUrl != null && article.imageUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(article.imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: article.imageUrl == null || article.imageUrl!.isEmpty
                    ? Icon(Icons.article_rounded, color: tagColor, size: 40)
                    : null,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              article.title, 
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 5.h),
            Text("اقرأ المزيد", style: TextStyle(fontSize: 10.sp, color: tagColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // هيدر الأقسام الصغير
  Widget _buildSectionHeader(String title, String subtitle, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
          ],
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text("عرض الكل", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF005DA3), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}