class DoctorModel {
  final String id;
  final String name;
  final String specialty;      // التخصص (باطنة، أسنان...)
  final String category;       // القسم الرئيسي (للربط مع الشاشة الأولى)
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final String location;
  final double price;
  final String about;
  final int experienceYears;
  final int patientsCount;     // عدد المرضى (لإظهار الإحصائيات)
  final bool isAvailable;      // هل هو متاح الآن؟ (للنقطة الخضراء)

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    required this.price,
    required this.about,
    required this.experienceYears,
    required this.patientsCount,
    this.isAvailable = true,
  });

  // 1️⃣ تحويل البيانات القادمة من الفايربيز (Map) إلى Model
  // (مهم جداً: التعامل مع القيم الفارغة عشان التطبيق مايعملش Crash)
  factory DoctorModel.fromMap(Map<String, dynamic> map, String docId) {
    return DoctorModel(
      id: docId,
      name: map['name'] ?? 'طبيب غير معروف',
      specialty: map['specialty'] ?? 'عام',
      category: map['category'] ?? 'عام',
      imageUrl: map['imageUrl'] ?? '', // لو فاضية بنعرض أيقونة بديلة في الـ UI
      rating: (map['rating'] ?? 0.0).toDouble(), // ضمان التحويل لـ double
      reviewsCount: map['reviewsCount'] ?? 0,
      location: map['location'] ?? 'غير محدد',
      price: (map['price'] ?? 0.0).toDouble(),
      about: map['about'] ?? 'لا توجد نبذة عن الطبيب حالياً.',
      experienceYears: map['experienceYears'] ?? 0,
      patientsCount: map['patientsCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? false,
    );
  }

  // 2️⃣ تحويل الـ Model إلى Map (عشان لو حبيت ترفع دكاترة من لوحة التحكم)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'location': location,
      'price': price,
      'about': about,
      'experienceYears': experienceYears,
      'patientsCount': patientsCount,
      'isAvailable': isAvailable,
    };
  }
}