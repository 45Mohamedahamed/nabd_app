class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // 'patient' OR 'doctor'
  final String? specialty; // للدكتور فقط
  final String? profileImage;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.specialty,
    this.profileImage,
  });

  // 📥 استقبال البيانات من Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'patient',
      specialty: map['specialty'],
      profileImage: map['profileImage'],
    );
  }

  // 📤 إرسال البيانات إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'specialty': specialty,
      'profileImage': profileImage,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}