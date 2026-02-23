import 'package:google_sign_in/google_sign_in.dart' as official; // 👈 استخدمنا اسم مستعار هنا
import 'package:firebase_auth/firebase_auth.dart';

class GoogleHelperFacade {
  // بننادي المكتبة باسمها المستعار عشان نضمن إننا بنكلم المكتبة الصح
  static final official.GoogleSignIn _googleSignIn = official.GoogleSignIn();

  static Future<AuthCredential?> signInAndGetCredential() async {
    try {
      // استخدام الاسم المستعار للوصول للدوال الأصلية
      final official.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null; 

      final official.GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      return GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
    } catch (e) {
      print("Google Facade Error: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print("SignOut Error: $e");
    }
  }
}