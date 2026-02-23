import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 👇 تأكد من صحة مسارات الملفات التالية حسب هيكلة مشروعك
import '../../core/layout/main_layout.dart';
import '../../auth/cubit/register_cubit.dart'; 

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1️⃣ توفير الكيوبت للشاشة (BlocProvider)
    // هذا يضمن أن RegisterCubit متاح لجميع الودجت تحت هذه الشجرة
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("إنشاء حساب جديد", style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        // تم فصل الـ Form في Widget منفصلة للحفاظ على نظافة الكود وتحسين الأداء
        body: const RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // --- Controllers ---
  // نستخدم هذه المتحكمات لجلب النصوص من الحقول
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool isObscure = true; // للتحكم في إظهار/إخفاء كلمة المرور
  final Color mainColor = const Color(0xFF005DA3); // اللون الرئيسي للتطبيق

  @override
  void dispose() {
    // تنظيف المتحكمات عند إغلاق الشاشة لتجنب تسريب الذاكرة
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocConsumer: يستمع للتغيرات في الحالة (Listener) ويعيد بناء الواجهة (Builder)
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          // ✅ في حالة النجاح: الانتقال للشاشة الرئيسية وحذف الشاشات السابقة من المكدس
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => const MainLayout()),
            (route) => false,
          );
        } else if (state is RegisterError) {
          // ❌ في حالة الفشل: عرض رسالة خطأ للمستخدم (SnackBar)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error), 
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating, // يجعل الرسالة تطفو فوق العناصر
            ),
          );
        }
      },
      builder: (context, state) {
        // واجهة المستخدم (UI)
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان الرئيسي
              Text("انضم لعائلة نبض", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: mainColor)),
              SizedBox(height: 5.h),
              Text("سجل بياناتك لإنشاء ملف طبي موحد", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              
              SizedBox(height: 30.h),

              // حقول الإدخال
              _buildTextField("الاسم الكامل", Icons.person_outline, _nameController),
              SizedBox(height: 15.h),
              _buildTextField("رقم الهاتف", Icons.phone_android_outlined, _phoneController, isNumber: true),
              SizedBox(height: 15.h),
              _buildTextField("البريد الإلكتروني", Icons.email_outlined, _emailController),
              SizedBox(height: 15.h),
              _buildTextField("كلمة المرور", Icons.lock_outline, _passwordController, isPassword: true),

              SizedBox(height: 30.h),

              // زر التسجيل العادي
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  // تعطيل الزر أثناء التحميل لمنع التكرار
                  onPressed: state is RegisterLoading 
                    ? null 
                    : () {
                        // تحقق بسيط من صحة المدخلات
                        if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى ملء جميع الحقول")));
                          return;
                        }
                        
                        // استدعاء دالة التسجيل من الكيوبت
                        context.read<RegisterCubit>().userRegister(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          name: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          userType: "patient",
                        );
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: state is RegisterLoading 
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text("إنشاء الحساب", style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              SizedBox(height: 20.h),

              // فاصل "أو سجل عبر"
              Row(children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10.w), child: Text("أو سجل عبر", style: TextStyle(color: Colors.grey))),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ]),

              SizedBox(height: 20.h),

              // 👇 أزرار التسجيل عبر السوشيال ميديا (Google & Facebook)
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      imagePath: 'assets/images/google.png', 
                      text: "Google", 
                      // استدعاء دالة تسجيل الدخول بجوجل من الكيوبت
                      onTap: () => context.read<RegisterCubit>().googleLogin(),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _buildSocialButton(
                      imagePath: 'assets/images/facebook.png', 
                      text: "Facebook", 
                      // استدعاء دالة تسجيل الدخول بفيسبوك من الكيوبت
                      onTap: () => context.read<RegisterCubit>().facebookLogin(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ودجت مخصصة لبناء حقول الإدخال بشكل موحد
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPassword = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && isObscure, // إخفاء النص إذا كان كلمة مرور
      keyboardType: isNumber ? TextInputType.phone : TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade50,
        // تنسيق الحواف (Borders)
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: mainColor)),
        // زر إظهار/إخفاء كلمة المرور
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                onPressed: () => setState(() => isObscure = !isObscure),
              )
            : null,
      ),
    );
  }

  // ودجت مخصصة لبناء أزرار السوشيال ميديا
  Widget _buildSocialButton({required String imagePath, required String text, required VoidCallback onTap}) {
    return InkWell( // استخدمنا InkWell لإضافة تأثير الضغط
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath, 
              height: 24.h, 
              width: 24.w, 
              // أيقونة احتياطية في حالة عدم وجود الصورة
              errorBuilder: (c,e,s) => const Icon(Icons.public, color: Colors.grey)
            ),
            SizedBox(width: 8.w),
            Text(text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}