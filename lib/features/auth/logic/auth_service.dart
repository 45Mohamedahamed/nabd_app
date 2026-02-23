import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../core/models/user_model.dart';

// 👇 السطر ده هو اللي بيحل مشكلة التعارض مع مكتبة جوجل
import 'google_helper_facade.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================================
  // 1️⃣ التسجيل التقليدي (Email & Password)
  // ==========================================================

  /// إنشاء حساب جديد
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'patient',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toMap());
          
    } catch (e) {
      throw Exception(_handleFirebaseAuthError(e));
    }
  }

  /// تسجيل الدخول العادي
  Future<UserModel> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception("بيانات المستخدم غير موجودة في قاعدة البيانات.");
      }

      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception(_handleFirebaseAuthError(e));
    }
  }

  // ==========================================================
  // 2️⃣ تسجيل الدخول الاجتماعي (Google & Facebook)
  // ==========================================================

  /// 🔥 تسجيل الدخول بجوجل (باستخدام الملف المعزول لمنع الأخطاء)
  Future<void> signInWithGoogle() async {
    try {
      // بننادي الـ Facade عشان نضمن إننا بنستخدم المكتبة الأصلية صح
      final AuthCredential? credential = await GoogleHelperFacade.signInAndGetCredential();

      if (credential == null) return; 

      UserCredential result = await _auth.signInWithCredential(credential);
      await _saveSocialUserToFirestore(result.user!);
      
    } catch (e) {
      throw Exception("فشل الدخول بجوجل: $e");
    }
  }

  /// 🔵 تسجيل الدخول بفيسبوك
  Future<void> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final AccessToken accessToken = loginResult.accessToken!;
        final AuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);
        UserCredential result = await _auth.signInWithCredential(credential);
        await _saveSocialUserToFirestore(result.user!);
      } else {
        throw Exception("فشل الدخول بفيسبوك");
      }
    } catch (e) {
      throw Exception("خطأ في فيسبوك: $e");
    }
  }

  // ==========================================================
  // 3️⃣ دوال مساعدة
  // ==========================================================

  Future<void> _saveSocialUserToFirestore(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();
    
    if (!docSnapshot.exists) {
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email ?? "",
        name: user.displayName ?? "No Name",
        phone: user.phoneNumber ?? "",
        role: "patient",
        profileImage: user.photoURL,
      );
      await docRef.set(newUser.toMap());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    try {
      // بنخرج من جوجل برضه من خلال الـ Facade
      await GoogleHelperFacade.signOut(); 
      await FacebookAuth.instance.logOut();
    } catch (e) {}
  }
  
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String _handleFirebaseAuthError(dynamic e) {
    String message = e.toString();
    if (message.contains('email-already-in-use')) return 'البريد الإلكتروني مستخدم بالفعل.';
    if (message.contains('wrong-password')) return 'كلمة المرور غير صحيحة.';
    if (message.contains('user-not-found')) return 'المستخدم غير موجود.';
    return 'حدث خطأ: ${message.replaceAll("Exception:", "").trim()}';
  }
}