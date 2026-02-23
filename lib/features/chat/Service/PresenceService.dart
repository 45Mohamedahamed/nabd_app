
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart'; // 👈 ده اللي هيعرف ServerValue
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  final _db = FirebaseDatabase.instance.ref();
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  void updateUserPresence() {
    if (_uid == null) return;

    // 1. مرجع حالة المستخدم في Realtime Database
    final userStatusRef = _db.child('status/$_uid');

    // 2. مراقبة الاتصال بالسيرفر
    FirebaseDatabase.instance.ref('.info/connected').onValue.listen((event) {
      if (event.snapshot.value == false) return;

      // 3. عند الانقطاع، حول الحالة لـ offline
      userStatusRef.onDisconnect().set({
        'state': 'offline',
        'last_changed': ServerValue.timestamp,
      }).then((_) {
        // 4. الآن وأنا متصل، اجعل الحالة online
        userStatusRef.set({
          'state': 'online',
          'last_changed': ServerValue.timestamp,
        });
      });
    });
  }
}