import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_service.dart'; // 👈 تأكد من مسار ملف السيرفس الصحيح

// ==========================================
// 1️⃣ الحالات (States)
// ==========================================
abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterError extends RegisterState {
  final String error;
  RegisterError(this.error);
}

// ==========================================
// 2️⃣ الكيوبت (Logic)
// ==========================================
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  // نسخة من السيرفس للتعامل مع الفايربيز
  final AuthService _authService = AuthService(); 

  /// 📩 التسجيل التقليدي (إيميل وباسورد)
  void userRegister({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType, // 'patient' or 'doctor'
  }) async {
    emit(RegisterLoading()); // ⏳ بدء التحميل

    try {
      await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: userType, 
      );

      emit(RegisterSuccess()); // ✅ نجاح
    } catch (e) {
      // تنظيف رسالة الخطأ من كلمة Exception
      emit(RegisterError(e.toString().replaceAll('Exception:', '').trim())); 
    }
  }

  /// 🔥 تسجيل الدخول بجوجل
  void googleLogin() async {
    emit(RegisterLoading()); // ⏳ بدء التحميل

    try {
      await _authService.signInWithGoogle();
      emit(RegisterSuccess()); // ✅ نجاح
    } catch (e) {
      emit(RegisterError(e.toString().replaceAll('Exception:', '').trim()));
    }
  }

  /// 🔵 تسجيل الدخول بفيسبوك
  void facebookLogin() async {
    emit(RegisterLoading()); // ⏳ بدء التحميل

    try {
      await _authService.signInWithFacebook();
      emit(RegisterSuccess()); // ✅ نجاح
    } catch (e) {
      emit(RegisterError(e.toString().replaceAll('Exception:', '').trim()));
    }
  }
}