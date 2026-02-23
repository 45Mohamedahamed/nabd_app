import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color mainColor = const Color(0xFF005DA3);
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  bool _isLoading = false;
  File? _imageFile;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  // 📡 1. جلب البيانات الحالية من الفايربيز عند فتح الشاشة
  Future<void> _loadCurrentData() async {
    if (currentUser == null) return;
    
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        nameController.text = data['name'] ?? currentUser!.displayName ?? "";
        phoneController.text = data['phone'] ?? "";
        _currentPhotoUrl = data['photoUrl'] ?? currentUser!.photoURL;
      });
    }
  }

  // 📸 2. اختيار صورة من الهاتف
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70); // ضغط الصورة 70%
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // 🚀 3. رفع البيانات والصورة للفايربيز
  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl = _currentPhotoUrl;

      // أ. لو المريض اختار صورة جديدة، نرفعها للـ Storage أولاً
      if (_imageFile != null) {
        Reference ref = FirebaseStorage.instance.ref().child('profile_images/${currentUser!.uid}.jpg');
        UploadTask uploadTask = ref.putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        newPhotoUrl = await snapshot.ref.getDownloadURL();
      }

      // ب. تحديث بيانات المستخدم في Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'photoUrl': newPhotoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge: true عشان منمسحش باقي بياناته (زي التأمين)

      // ج. تحديث بيانات الـ Auth (عشان تظهر في باقي التطبيق فوراً)
      await currentUser!.updateDisplayName(nameController.text.trim());
      if (newPhotoUrl != null) await currentUser!.updatePhotoURL(newPhotoUrl);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تحديث البيانات بنجاح ✅"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("تعديل البيانات", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 📸 صورة البروفايل التفاعلية
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120.w, height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200, width: 3),
                        image: _imageFile != null
                            ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                            : (_currentPhotoUrl != null
                                ? DecorationImage(image: NetworkImage(_currentPhotoUrl!), fit: BoxFit.cover)
                                : null),
                      ),
                      child: (_imageFile == null && _currentPhotoUrl == null)
                          ? Icon(Icons.person, size: 60.sp, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40.h),

            // ✍️ الحقول
            _buildEditField("الاسم بالكامل", nameController, Icons.person_outline),
            SizedBox(height: 20.h),
            
            // البريد لا يتعدل من هنا (لأنه مرتبط بالـ Auth الأساسي)
            _buildReadOnlyField("البريد الإلكتروني", currentUser?.email ?? "", Icons.email_outlined),
            SizedBox(height: 20.h),
            
            _buildEditField("رقم الهاتف", phoneController, Icons.phone_outlined, isNumber: true),
            
            SizedBox(height: 40.h),

            // 💾 زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("حفظ التغييرات", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: mainColor),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide(color: mainColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}