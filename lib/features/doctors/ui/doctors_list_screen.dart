import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../clinics/model/doctor_model.dart';
import '../../clinics/service/clinic_service.dart';
import '../ui/DoctorDetailsScreen.dart'; // تأكد أن المسار صحيح

class DoctorsListScreen extends StatefulWidget {
  final String initialCategory; // القسم المختار

  const DoctorsListScreen({super.key, this.initialCategory = "الكل"});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  late String _selectedCategory;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ["الكل", "باطنة", "أسنان", "عظام", "عيون", "قلب", "جلدية", "أطفال"];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1️⃣ الهيدر الفخم (من شاشة العيادات)
          SliverAppBar(
            expandedHeight: 140.h,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r))),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("أطباء $_selectedCategory", 
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.medical_services_outlined, size: 60.sp, color: Colors.white10),
                ),
              ),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list, color: Colors.white)),
            ],
          ),

          // 2️⃣ شريط البحث والفلترة (مثبت أسفل الهيدر)
          SliverToBoxAdapter(
            child: Column(
              children: [
                // مربع البحث الأنيق
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: "ابحث عن طبيب أو تخصص...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            }) 
                          : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                    ),
                  ),
                ),

                // شريط الأقسام (Chips)
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: SizedBox(
                    height: 45.h,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedCategory = cat),
                            selectedColor: const Color(0xFF1A237E),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),

          // 3️⃣ قائمة الأطباء (Live Data from Firebase)
          StreamBuilder<List<DoctorModel>>(
            stream: ClinicService().getDoctors(category: _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              
              // معالجة البيانات والبحث
              final doctors = (snapshot.data ?? []).where((doc) {
                return doc.name.contains(_searchQuery) || doc.specialty.contains(_searchQuery);
              }).toList();

              if (doctors.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState());
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: _buildDoctorCard(doctors[index]),
                      );
                    },
                    childCount: doctors.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- تصميم كارت الطبيب (النسخة المحسنة) ---
  Widget _buildDoctorCard(DoctorModel doctor) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DoctorDetailsScreen(doctor: doctor))),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الطبيب
            Stack(
              children: [
                Hero(
                  tag: doctor.id,
                  child: Container(
                    width: 75.w,
                    height: 75.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      color: Colors.grey.shade100,
                      image: doctor.imageUrl.isNotEmpty 
                        ? DecorationImage(image: NetworkImage(doctor.imageUrl), fit: BoxFit.cover)
                        : null,
                    ),
                    child: doctor.imageUrl.isEmpty 
                        ? Icon(Icons.person, color: Colors.grey.shade400, size: 35.sp) 
                        : null,
                  ),
                ),
                // نقطة الحالة (Online)
                Positioned(
                  bottom: 5, right: 5,
                  child: Container(
                    width: 12.w, height: 12.w,
                    decoration: BoxDecoration(
                      color: doctor.isAvailable ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                )
              ],
            ),
            
            SizedBox(width: 15.w),

            // التفاصيل
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(doctor.name, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6.r)),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 12.sp, color: Colors.amber[700]),
                            SizedBox(width: 3.w),
                            Text("${doctor.rating}", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.amber[800])),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(doctor.specialty, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                  SizedBox(height: 8.h),
                  
                  // السعر وزر الحجز
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${doctor.price} ج.م", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text("حجز", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 70.sp, color: Colors.grey.shade300),
          SizedBox(height: 15.h),
          Text("لم يتم العثور على أطباء", style: TextStyle(color: Colors.grey.shade500, fontSize: 16.sp)),
        ],
      ),
    );
  }
}