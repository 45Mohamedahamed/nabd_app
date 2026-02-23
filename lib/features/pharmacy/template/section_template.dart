import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';

// 👇 تأكد من صحة المسارات
import '../service/pharmacy_service.dart'; // السيرفيس
import '../service/cart_provider.dart'; // بروفايدر السلة
import '../model/product_model.dart';
import '../ui/care_screen.dart'; // 👈 هام: استدعاء شاشة السلة الحقيقية

class PharmacySectionTemplate extends StatefulWidget {
  final String title;
  final String categoryId;
  final bool isAdmin;
  final Color primaryColor;
  final IconData sectionIcon;

  const PharmacySectionTemplate({
    super.key,
    required this.title,
    required this.categoryId,
    required this.isAdmin,
    required this.primaryColor,
    required this.sectionIcon,
  });

  @override
  State<PharmacySectionTemplate> createState() => _PharmacySectionTemplateState();
}

class _PharmacySectionTemplateState extends State<PharmacySectionTemplate> {
  final PharmacyService _service = PharmacyService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // 👇 تصحيح الخطأ: الانتقال لشاشة السلة CartScreen
          IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
               context,
                // تم حذف const من السطر التالي ليعمل الكود بدون أخطاء
               MaterialPageRoute(builder: (c) => CareScreen(isAdmin: false)), 
              ),
          )
        
        ],
      ),
      body: Column(
        children: [
          // هيدر البحث
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: widget.primaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
            ),
            child: Column(
              children: [
                Icon(widget.sectionIcon, size: 50.sp, color: Colors.white.withOpacity(0.8)),
                SizedBox(height: 15.h),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "بحث في ${widget.title}...",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          // عرض البيانات
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _service.getProductsByCategory(widget.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: widget.primaryColor));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("لا توجد منتجات حالياً", style: TextStyle(fontSize: 16.sp)));
                }

                var displayList = snapshot.data!.where((element) {
                  return element.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.all(15.w),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final item = displayList[index];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: _buildProductCard(item),
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

  Widget _buildProductCard(ProductModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10.r)),
            child: Icon(Icons.image, color: Colors.grey.shade300, size: 40.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                Text(item.manufacturer, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                if (item.requiresPrescription)
                  Text("يحتاج روشتة ⚠️", style: TextStyle(color: Colors.red, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                Text("${item.price} ج.م", style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_shopping_cart, color: widget.primaryColor),
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).addToCart(item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تمت إضافة ${item.name} للسلة ✅"), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
              );
            },
          )
        ],
      ),
    );
  }
}