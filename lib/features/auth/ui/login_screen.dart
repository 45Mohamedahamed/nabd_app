import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
// 👇 استدعاءات مهمة (تأكد من المسارات)
import '../../core/layout/main_layout.dart'; // شاشة المريض
import '../../../features/doctor_dashboard/ui/doctor_home_screen.dart'; // شاشة الطبيب
import '../logic/auth_service.dart'; // السيرفس الحقيقي
import 'RegisterScreen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Services & Controllers ---
  final AuthService _authService = AuthService(); // السيرفس الحقيقي
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool isObscure = true;
  bool _isLoading = false;
  final Color mainColor = const Color(0xFF005DA3);

  // ==========================================
  // 🔐 1. منطق تسجيل الدخول (Email & Password)
  // ==========================================
  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى ملء جميع الحقول"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ استدعاء السيرفس الحقيقي
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim()
      );

      if (!mounted) return;
      
      // ✅ التوجيه حسب الدور (Role)
      if (user.role == 'doctor') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const DoctorDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainLayout()));
      }
      
    } catch (e) {
      // ❌ عرض رسالة الخطأ (تم تنظيفها في السيرفس)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll('Exception:', '')), 
        backgroundColor: Colors.red
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // 🔥 2. منطق الدخول بجوجل
  // ==========================================
  Future<void> _signInWithGoogle() async { 
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (!mounted) return;
      // بعد نجاح الدخول، ننتقل للشاشة الرئيسية (الافتراضي مريض)
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainLayout()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception:', '')), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // 🔵 3. منطق الدخول بفيسبوك
  // ==========================================
  Future<void> _signInWithFacebook() async { 
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithFacebook();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainLayout()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception:', '')), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // زر الرجوع
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              
              // 1. Logo
              FadeInDown(
                duration: const Duration(milliseconds: 1000),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 150.h,
                  width: 150.w,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(Icons.health_and_safety, size: 100.sp, color: mainColor),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // 2. Title
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text("تسجيل الدخول", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: mainColor)),
              ),
              
              SizedBox(height: 30.h),

              // 3. Email Field
              FadeInLeft(
                delay: const Duration(milliseconds: 400),
                child: _buildTextField(_emailController, "البريد الإلكتروني", Icons.email_outlined),
              ),
              
              SizedBox(height: 16.h),
              
              // 4. Password Field
              FadeInLeft(
                delay: const Duration(milliseconds: 600),
                child: _buildTextField(_passwordController, "كلمة المرور", Icons.lock_outline, isPassword: true),
              ),

              SizedBox(height: 10.h),
              
              // 5. Forgot Password
              FadeIn(
                delay: const Duration(milliseconds: 700),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                    child: Text("نسيت كلمة المرور؟", style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // 6. Login Button
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("تسجيل الدخول", style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // 7. Social Login Section
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text("أو سجل عبر", style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              FadeInUp(
                delay: const Duration(milliseconds: 1100),
                child: Row(
                  children: [
                    // زر جوجل
                    Expanded(child: _buildSocialButton(imagePath: 'assets/images/google.png', text: "Google", onTap: _signInWithGoogle)),
                    SizedBox(width: 15.w),
                    // زر فيسبوك
                    Expanded(child: _buildSocialButton(imagePath: 'assets/images/facebook.png', text: "Facebook", onTap: _signInWithFacebook)),
                  ],
                ),
              ),
              
              SizedBox(height: 30.h),

              // 8. Sign Up Link
              FadeInUp(
                delay: const Duration(milliseconds: 1200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ليس لديك حساب؟ "),
                    GestureDetector(
                      // عند الضغط ينتقل لصفحة التسجيل (RegisterScreen)
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
                      child: Text("انشئ حساب الآن", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && isObscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: mainColor)),
        suffixIcon: isPassword
            ? IconButton(icon: Icon(isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => isObscure = !isObscure))
            : null,
      ),
    );
  }

  Widget _buildSocialButton({required String imagePath, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 24.h,
              width: 24.w,
              // أيقونة بديلة في حالة عدم وجود الصورة
              errorBuilder: (c,e,s) => const Icon(Icons.public, size: 24, color: Colors.grey),
            ),
            SizedBox(width: 8.w),
            Text(text, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}