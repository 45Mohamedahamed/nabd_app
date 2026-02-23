import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../model/BloodUnitModel.dart';
class BloodBankScreen extends StatefulWidget {
  final bool isDoctor;
  const BloodBankScreen({super.key, this.isDoctor = false});

  @override
  State<BloodBankScreen> createState() => _BloodBankScreenState();
}

class _BloodBankScreenState extends State<BloodBankScreen> {
  // --- 🔒 فورم الحجز الحساس (Sensitive Booking Form) ---
  void _showSensitiveBookingForm(BloodUnitModel unit) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController nationalIdController = TextEditingController();
    final TextEditingController hospitalController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("طلب وحدة دم فصيلة ${unit.type} 🚑", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 10.h),
                Text("يجب إدخال البيانات الرسمية لمطابقة الحالة", style: TextStyle(fontSize: 12.sp, color: Colors.red)),
                SizedBox(height: 20.h),
                _buildField(nameController, "اسم المريض بالكامل", Icons.person),
                _buildField(nationalIdController, "الرقم القومي (14 رقم)", Icons.badge, isNumeric: true),
                _buildField(hospitalController, "اسم المستشفى المتواجد بها", Icons.local_hospital),
                SizedBox(height: 20.h),
                // زر رفع التقرير (محاكاة)
                OutlinedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.upload_file), 
                  label: const Text("ارفع تقرير الحالة الطبي (PDF/Image)")
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))),
                    onPressed: () => _submitRequest(unit, nameController.text, nationalIdController.text, hospitalController.text),
                    child: const Text("تأكيد الطلب الرسمي", style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitRequest(BloodUnitModel unit, String name, String id, String hospital) async {
    // 🔐 حفظ البيانات الحساسة في كوليكشن الطلبات
    await FirebaseFirestore.instance.collection('blood_requests').add({
      'patientName': name,
      'nationalId': id, // في الحقيقة يفضل تشفيره
      'hospitalName': hospital,
      'bloodType': unit.type,
      'status': 'Pending Verification',
      'requestTime': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال طلبك.. جاري المراجعة الطبية ⏳")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blood_inventory').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("حدث خطأ في الاتصال"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          List<BloodUnitModel> units = snapshot.data!.docs.map((doc) => BloodUnitModel.fromFirestore(doc)).toList();

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(units),
              SliverPadding(
                padding: EdgeInsets.all(20.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 15.w, mainAxisSpacing: 15.h, childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAdvancedBloodCard(units[index], index),
                    childCount: units.length,
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  // --- 🎨 ويدجت الكارت المبدع ---
  Widget _buildAdvancedBloodCard(BloodUnitModel unit, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10))],
          border: Border.all(color: unit.quantity < 10 ? Colors.red.shade200 : Colors.transparent),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // أنيميشن النبض للحالات الحرجة
                  if (unit.quantity < 10)
                    Pulse(infinite: true, child: Container(width: 80.w, height: 80.w, decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle))),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(unit.type, style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: const Color(0xFFB71C1C))),
                      Text("${unit.quantity} كيس", style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            // الزر السفلي
            GestureDetector(
              onTap: () => widget.isDoctor ? _updateStock(unit) : _showSensitiveBookingForm(unit),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: widget.isDoctor ? Colors.blueGrey : (unit.quantity > 0 ? const Color(0xFFB71C1C) : Colors.grey),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25.r)),
                ),
                child: Center(
                  child: Text(
                    widget.isDoctor ? "تحديث المخزون" : (unit.quantity > 0 ? "حجز طارئ" : "غير متوفر"),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🛠️ دوال مساعدة ---
  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFB71C1C)),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(List<BloodUnitModel> units) {
    int total = units.fold(0, (sum, item) => sum + item.quantity);
    return SliverAppBar(
      expandedHeight: 180.h,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFB71C1C),
      flexibleSpace: FlexibleSpaceBar(
        title: Text("بنك الدم الذكي", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        background: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.bloodtype, size: 150.sp, color: Colors.white.withOpacity(0.1)),
            Positioned(
              bottom: 60.h,
              child: Text("إجمالي المخزون: $total كيس", style: TextStyle(color: Colors.white, fontSize: 18.sp)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStock(BloodUnitModel unit) {
    // كود تحديث الفايربيز للدكتور
    FirebaseFirestore.instance.collection('blood_inventory').doc(unit.id).update({
      'quantity': unit.quantity + 5, // مثال للزيادة السريعة
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }
}