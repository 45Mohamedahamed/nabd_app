import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../model/wellness_model.dart';
import '../../Medical Encyclopedia/Service/medical_content_service.dart';

  bool _isLoading = false;
class AddWellnessContentScreen extends StatefulWidget {
  const AddWellnessContentScreen({super.key});

  @override
  State<AddWellnessContentScreen> createState() => _AddWellnessContentScreenState();
}

class _AddWellnessContentScreenState extends State<AddWellnessContentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  
  // Selections
  String _selectedCategory = "تغذية";
  ContentType _selectedType = ContentType.article;
  final List<String> _categories = ["تغذية", "صحة نفسية", "لياقة", "عادات صحية", "إسعافات"];

  // 👈 لا تنسَ استدعاء السيرفيس فوق


  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final newItem = WellnessItem(
          id: '', // الفايربيز سيكتب الـ ID تلقائياً
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          author: _authorController.text.trim().isEmpty ? "طبيب متخصص" : _authorController.text.trim(),
          category: _selectedCategory,
          type: _selectedType,
          date: DateTime.now(), // سيتم استبداله بتوقيت السيرفر في toMap
        );

        // 📡 رفع للفايربيز
        await MedicalContentService().addWellnessContent(newItem);

        if (!mounted) return;
        Navigator.pop(context); // الرجوع للشاشة السابقة
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة محتوى جديد"), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. نوع المحتوى
              Text("نوع المحتوى:", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<ContentType>(
                      title: const Text("مقال"),
                      value: ContentType.article,
                      groupValue: _selectedType,
                      activeColor: Colors.teal,
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<ContentType>(
                      title: const Text("نصيحة"),
                      value: ContentType.tip,
                      groupValue: _selectedType,
                      activeColor: Colors.teal,
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                  ),
                ],
              ),

              const Divider(),

              // 2. الحقول
              _buildTextField("العنوان", _titleController, icon: Icons.title),
              
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "التصنيف",
                  prefixIcon: const Icon(Icons.category, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              
              SizedBox(height: 15.h),

              _buildTextField(
                _selectedType == ContentType.tip ? "نص النصيحة" : "محتوى المقال", 
                _contentController, 
                maxLines: _selectedType == ContentType.tip ? 3 : 8
              ),
              
              _buildTextField("اسم الكاتب / الطبيب", _authorController, icon: Icons.person),

              SizedBox(height: 30.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text("نشر المحتوى", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
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
        validator: (val) => val!.isEmpty ? "مطلوب" : null,
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