import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../model/medical_models.dart';
import '../../Health & Wellness/ui/disease_detail_screen.dart';
import '../../Health & Wellness/ui/add_disease_screen.dart'; // ✅ شاشة الإضافة
import '../Service/medical_content_service.dart'; // ✅ خدمة المحتوى الطبي (للقراءة والكتابة)
class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen> {
  // 🔐 صلاحية الأدمن (True = الزر يظهر)
  bool isAdmin = true; 

  // 🏷️ التصنيف المختار حالياً
  String selectedCategory = "الكل";
  final List<String> categories = ["الكل", "القلب", "الباطنة", "الجلدية", "الأعصاب", "أطفال"];

  // 🗂️ قائمة الأمراض (Mock Data)
  List<DiseaseModel> diseases = [
    DiseaseModel(
      id: "1",
      name: "مرض السكري (النوع الثاني)",
      category: "الباطنة",
      imageUrl: "https://img.freepik.com/free-vector/blood-test-concept-illustration_114360-1200.jpg",
      brief: "اضطراب مزمن يؤثر على استقلاب الجلوكوز في الجسم.",
      overview: "داء السكري من النوع 2 هو حالة طويلة الأمد تؤدي إلى ارتفاع مستوى السكر في الدم...",
      symptoms: ["العطش الشديد", "كثرة التبول", "الجوع المستمر", "فقدان الوزن"],
      riskFactors: ["السمنة", "الخمول", "التاريخ العائلي"],
      prevention: ["تقليل السكريات", "ممارسة الرياضة 30 دقيقة يومياً", "الحفاظ على وزن صحي"],
      treatments: ["ميتفورمين", "حقن الأنسولين", "الحمية الغذائية"],
      sourceName: "منظمة الصحة العالمية (WHO)",
      lastUpdated: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // تصفية القائمة بناءً على التصنيف المختار
    List<DiseaseModel> filteredDiseases = selectedCategory == "الكل"
        ? diseases
        : diseases.where((d) => d.category.contains(selectedCategory)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("الموسوعة الطبية", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.grey), onPressed: () {})],
      ),
      
      // 🛡️ زر الإضافة (يظهر فقط للأدمن)
      floatingActionButton: isAdmin 
          ? FloatingActionButton.extended(
              heroTag: "add_disease_btn",
              onPressed: () async {
                // 1. الذهاب لشاشة الإضافة وانتظار النتيجة
                final newDisease = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AddDiseaseScreen()),
                );

                // 2. لو رجعنا ببيانات، نضيفها للقائمة ونحدث الشاشة
                if (newDisease != null && newDisease is DiseaseModel) {
                  setState(() {
                    diseases.insert(0, newDisease); // إضافة في الأول
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Text("تمت إضافة المرض بنجاح")]),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              backgroundColor: const Color(0xFF005DA3),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("إضافة مرض", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,

      body: Column(
        children: [
          // 1. شريط التصنيفات (Filters)
          Container(
            height: 60.h,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              itemCount: categories.length,
              separatorBuilder: (c, i) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                bool isSelected = selectedCategory == categories[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = categories[index]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF005DA3) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      categories[index],
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
          ),
          
          // 2. قائمة الأمراض
         Expanded(
            child: StreamBuilder<List<DiseaseModel>>(
              stream: MedicalContentService().getDiseasesStream(), // 📡 قراءة لايف
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

                final allDiseases = snapshot.data!;
                // الفلترة المحلية بناءً على التصنيف المختار
                final filteredDiseases = selectedCategory == "الكل" 
                    ? allDiseases 
                    : allDiseases.where((d) => d.category == selectedCategory).toList();

                if (filteredDiseases.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: EdgeInsets.all(15.w),
                  itemCount: filteredDiseases.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: _buildDiseaseCard(context, filteredDiseases[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  // كارت المرض (تصميم محسن)
  Widget _buildDiseaseCard(BuildContext context, DiseaseModel disease) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.r),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DiseaseDetailScreen(disease: disease))),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصورة
                Hero(
                  tag: disease.id, // انيميشن الانتقال
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50, 
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: disease.imageUrl.isNotEmpty && disease.imageUrl.startsWith('http')
                          ? Image.network(
                              disease.imageUrl, 
                              fit: BoxFit.cover,
                              errorBuilder: (c,e,s) => Icon(Icons.broken_image, color: Colors.grey, size: 30.sp),
                            )
                          : Icon(Icons.medical_services_outlined, color: const Color(0xFF005DA3), size: 35.sp),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                
                // النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(disease.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 5.h),
                      Text(disease.brief, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], height: 1.4)),
                      SizedBox(height: 10.h),
                      
                      // التصنيف
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF005DA3).withOpacity(0.08), 
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          disease.category, 
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF005DA3), fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // حالة عدم وجود بيانات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80.sp, color: Colors.grey[300]),
          SizedBox(height: 10.h),
          Text("لا توجد أمراض في هذا التصنيف", style: TextStyle(color: Colors.grey[500], fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}