import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../model/lab_test_model.dart';
import '../service/lab_service.dart';
import '../widgets/lab_booking_sheet.dart';
class LabsScreen extends StatefulWidget {
  const LabsScreen({super.key});

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  // 1️⃣ متغيرات الحالة (State Variables)
  String _selectedCategory = "الكل";
  final List<LabTestModel> _labCart = []; // سلة التحاليل
  final List<String> _categories = [
    "الكل",
    "Hematology دم",
    "Biochemistry كيمياء",
    "Hormones هرمونات",
    "Vitamins فيتامينات",
    "Tumor Markers أورام"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("المختبر الذكي", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          _buildCartBadge(), // أيقونة السلة مع عداد الأصناف
        ],
      ),
      body: Column(
        children: [
          // زر رفع الروشتة الذكي (AI Scan)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
            child: _buildPrescriptionButton(),
          ),

          // فلاتر التصنيفات
          _buildCategoryFilter(),

          // قائمة التحاليل (Real-time from Firebase)
          Expanded(
            child: StreamBuilder<List<LabTestModel>>(
              stream: LabService().getTestsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final tests = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      delay: Duration(milliseconds: 50 * index),
                      child: _buildTestCard(tests[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // زر عائم يظهر عند وجود تحاليل في السلة لاتمام الحجز
     floatingActionButton: _labCart.isNotEmpty
    ? FadeInRight(
        duration: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: () {
            // استدعاء شاشة ملخص الحجز (الملف الخارجي)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => LabBookingSheet(
                labCart: _labCart,
                onBookingComplete: () {
                  // تحديث الواجهة الرئيسية وتفريغ السلة بعد نجاح الحجز
                  setState(() {
                    _labCart.clear();
                  });
                },
              ),
            );
          },
          backgroundColor: const Color(0xFF6A1B9A),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: Text(
            "إتمام الحجز (${_labCart.length})",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
    : null,
    );  
  }

  // 📸 زر رفع الروشتة الإبداعي (AI Vision)
  Widget _buildPrescriptionButton() {
    return FadeInRight(
      child: InkWell(
        onTap: () => _handlePrescriptionUpload(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
              SizedBox(width: 10.w),
              Text(
                "رفع الروشتة وتحديد التحاليل بالذكاء الاصطناعي",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧪 كارت التحليل المطور مع نظام الإضافة للسلة
  Widget _buildTestCard(LabTestModel test) {
    bool isInCart = _labCart.any((item) => item.id == test.id);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isInCart ? Border.all(color: const Color(0xFF6A1B9A), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: const Color(0xFF6A1B9A).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.biotech_rounded, color: const Color(0xFF6A1B9A), size: 30.sp),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(test.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                    SizedBox(height: 4.h),
                    Text("النتيجة خلال: ${test.resultDuration}", style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                  ],
                ),
              ),
              Text("${test.price} ج.م", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 16.sp)),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHomeServiceBadge(test.homeSampleAvailable),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isInCart) {
                      _labCart.removeWhere((item) => item.id == test.id);
                    } else {
                      _labCart.add(test);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.red.shade50 : const Color(0xFF6A1B9A),
                  foregroundColor: isInCart ? Colors.red : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text(isInCart ? "حذف من السلة" : "إضافة للسلة"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- ميزات إضافية (Helper Widgets) ---

  Widget _buildCartBadge() {
    return Padding(
      padding: EdgeInsets.only(right: 15.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: () => _labCart.isNotEmpty ? _showHomeBookingSheet() : null,
            icon: const Icon(Icons.shopping_basket_outlined, size: 28),
          ),
          if (_labCart.isNotEmpty)
            Positioned(
              right: 8, top: 8,
              child: CircleAvatar(
                radius: 9.r,
                backgroundColor: Colors.red,
                child: Text("${_labCart.length}", style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 65.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6A1B9A) : Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: isSelected ? [BoxShadow(color: Colors.purple.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Center(
                child: Text(_categories[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeServiceBadge(bool available) {
    return available 
      ? Row(
          children: [
            const Icon(Icons.house_siding_rounded, color: Colors.blue, size: 18),
            SizedBox(width: 5.w),
            Text("متاح زيارة منزلية", style: TextStyle(color: Colors.blue, fontSize: 11.sp, fontWeight: FontWeight.w600)),
          ],
        )
      : const SizedBox();
  }

  // --- Functions (Logic) ---

  void _handlePrescriptionUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("جاري فتح الكاميرا للمسح الذكي (AI Integration)... 📸")),
    );
  }

  void _showHomeBookingSheet() {
    // كود نافذة الحجز المنزلي الذي أرسلته سابقاً يوضع هنا لفتح ملخص السلة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم فتح سلة التحاليل لتأكيد الحجز 🏠")),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80.sp, color: Colors.grey.shade300),
          SizedBox(height: 10.h),
          const Text("لا توجد تحاليل متاحة حالياً", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}