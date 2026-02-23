import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../incubators/model/IncubatorModel.dart';
import '../../incubators/Service/IncubatorService.dart';

class IncubatorBookingSheet extends StatefulWidget {
  final IncubatorModel unit;
  const IncubatorBookingSheet({super.key, required this.unit});

  @override
  State<IncubatorBookingSheet> createState() => _IncubatorBookingSheetState();
}

class _IncubatorBookingSheetState extends State<IncubatorBookingSheet> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        left: 20.w, right: 20.w, top: 20.h
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 20.h),
            
            // عنوان جذاب
            Text("حجز وحدة: ${widget.unit.name}", 
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.indigo)),
            Text("يرجى إدخال بيانات المولود لتسجيل الدخول", 
              style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            
            SizedBox(height: 25.h),

            // حقل اسم الطفل
            _buildTextField(
              controller: _nameController,
              label: "اسم الطفل المولد",
              icon: Icons.child_care,
              hint: "مثال: أحمد محمد علي",
            ),
            
            SizedBox(height: 15.h),

            // حقل الوزن
            _buildTextField(
              controller: _weightController,
              label: "الوزن الحالي (جرام)",
              icon: Icons.monitor_weight_outlined,
              hint: "مثال: 1500",
              isNumber: true,
            ),

            SizedBox(height: 30.h),

            // زر الحجز المبدع
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  elevation: 5,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("تأكيد الحجز وتشغيل الوحدة", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isNumber = false,
  }) {
    return FadeInRight(
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.indigo),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: const BorderSide(color: Colors.indigo)),
        ),
        validator: (val) => val!.isEmpty ? "هذا الحقل مطلوب" : null,
      ),
    );
  }

  // 🚀 الربط مع السيرفس بدقة
  void _handleBooking() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await IncubatorService().bookIncubator(
          widget.unit.id,
          _nameController.text,
          double.parse(_weightController.text),
        );
        if (mounted) {
          Navigator.pop(context); // إغلاق الشيت
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم الحجز بنجاح.. الوحدة الآن قيد التشغيل 👶✅"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
      }
    }
  }
}