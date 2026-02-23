import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});
  final Color mainColor = const Color(0xFF005DA3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Articles", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // البحث
            TextField(
              decoration: InputDecoration(
                hintText: "Search articles...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
              ),
            ),
            
            SizedBox(height: 20.h),

            // الفلاتر (Popular Articles)
            Text("Popular Articles", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip("Covid-19", true),
                  _buildChip("Diet", false),
                  _buildChip("Fitness", false),
                  _buildChip("Mental Health", false),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Trending Articles (Horizontal List)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Trending Articles", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text("See all", style: TextStyle(color: mainColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildArticleCard("Comparing the AstraZeneca...", "Covid-19", "Jun 12, 2021", "assets/images/article1.png"),
                  _buildArticleCard("The Horror Of The Second Wave", "Covid-19", "Jun 10, 2021", "assets/images/article2.png"),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Related Articles (Vertical List)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Related Articles", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text("See all", style: TextStyle(color: mainColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10.h),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildRelatedTile("The 25 Healthiest Fruits", "Jun 10, 2021", "assets/images/fruit.png"),
                _buildRelatedTile("Traditional Herbal Medicine", "Jun 9, 2021", "assets/images/herbal.png"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? mainColor : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: isSelected ? mainColor : Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildArticleCard(String title, String tag, String date, String image) {
    return Container(
      width: 150.w,
      margin: EdgeInsets.only(right: 15.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.r),
              // image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
            ),
            child: const Center(child: Icon(Icons.article, color: Colors.grey)), // Placeholder
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(5.r)),
            child: Text(tag, style: TextStyle(color: mainColor, fontSize: 10.sp, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 5.h),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
              Icon(Icons.bookmark_border, size: 16.sp, color: mainColor),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRelatedTile(String title, String date, String image) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 60.w, height: 60.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 5.h),
                Text(date, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              ],
            ),
          ),
          Icon(Icons.bookmark, color: mainColor, size: 20.sp),
        ],
      ),
    );
  }
}