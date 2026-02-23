import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Medical Encyclopedia/model/medical_models.dart';
import '../../Medical Encyclopedia/Service/medical_content_service.dart';
class AddDiseaseScreen extends StatefulWidget {
  const AddDiseaseScreen({super.key});

  @override
  State<AddDiseaseScreen> createState() => _AddDiseaseScreenState();
}

class _AddDiseaseScreenState extends State<AddDiseaseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _briefController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController(); // مفصول بفاصلة
  final TextEditingController _preventionController = TextEditingController(); // مفصول بفاصلة
  final TextEditingController _treatmentsController = TextEditingController(); // مفصول بفاصلة
  bool _isLoading = false; // ضيف المتغير ده فوق

  void _saveDisease() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final newDisease = DiseaseModel(
          id: '', // الفايربيز هيعمله
          name: _nameController.text.trim(),
          category: _categoryController.text.trim(),
          imageUrl: "", 
          brief: _briefController.text.trim(),
          overview: _overviewController.text.trim(),
          symptoms: _symptomsController.text.split('،').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          riskFactors: [], 
          prevention: _preventionController.text.split('،').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          treatments: _treatmentsController.text.split('،').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          sourceName: "المركز الطبي",
          lastUpdated: DateTime.now(),
        );

        await MedicalContentService().addDisease(newDisease); // 📡 رفع للفايربيز
        
        if(mounted) {
           Navigator.pop(context);
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم النشر بنجاح"), backgroundColor: Colors.green));
        }
      } catch (e) {
         // معالجة الخطأ
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }
  // (وخلي زرار الحفظ يظهر `CircularProgressIndicator` لو `_isLoading == true`)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة مرض جديد"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("اسم المرض", _nameController, icon: Icons.title),
              _buildTextField("التصنيف (مثلاً: باطنة)", _categoryController, icon: Icons.category),
              _buildTextField("نبذة مختصرة", _briefController, maxLines: 2),
              _buildTextField("نظرة عامة وشاملة", _overviewController, maxLines: 5),
              
              const Divider(),
              Text("للقوائم، افصل بين العناصر بفاصلة (،)", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              SizedBox(height: 10.h),

              _buildTextField("الأعراض (افصل بـ ،)", _symptomsController, icon: Icons.warning_amber),
              _buildTextField("الوقاية (افصل بـ ،)", _preventionController, icon: Icons.shield_outlined),
              _buildTextField("طرق العلاج (افصل بـ ،)", _treatmentsController, icon: Icons.medication),

              SizedBox(height: 30.h),
              
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _saveDisease,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF005DA3)),
                  child: const Text("حفظ ونشر", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "هذا الحقل مطلوب" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}