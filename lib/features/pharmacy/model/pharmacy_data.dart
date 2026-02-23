import 'product_model.dart'; // استدعاء الموديل من نفس المجلد

class PharmacyData {
  // 💊 قسم الأدوية
  static List<ProductModel> medicines = [
    ProductModel(
        id: "m1",
        name: "Panadol Extra",
        category: "medicines",
        price: 45,
        description: "أقراص مسكنة للألم وخافضة للحرارة.",
        imageUrl: "panadol_extra",
        manufacturer: "GSK",
        stock: 200),
    ProductModel(
        id: "m2",
        name: "Cataflam 50mg",
        category: "medicines",
        price: 33,
        description: "مسكن سريع المفعول لآلام الأسنان.",
        imageUrl: "cataflam",
        manufacturer: "Novartis",
        stock: 80),
  ];

  // 🍊 قسم الفيتامينات
  static List<ProductModel> vitamins = [
    ProductModel(
        id: "v1",
        name: "C-Retard 500mg",
        category: "vitamins",
        price: 45,
        description: "كبسولات فيتامين سي للمناعة.",
        imageUrl: "c_retard",
        manufacturer: "Hikma",
        stock: 150),
  ];

  // 🧴 قسم العناية الشخصية
  static List<ProductModel> personalCare = [
    ProductModel(
        id: "c1",
        name: "La Roche-Posay Cleanser",
        category: "care",
        price: 450,
        description: "غسول للبشرة الدهنية.",
        imageUrl: "laroche_cleanser",
        manufacturer: "La Roche-Posay",
        stock: 50),
  ];

  // 🩺 قسم المعدات الطبية
  static List<ProductModel> equipment = [
    ProductModel(
        id: "e1",
        name: "Beurer Pressure Monitor",
        category: "equipment",
        price: 1450,
        description: "جهاز قياس ضغط الدم.",
        imageUrl: "pressure_beurer",
        manufacturer: "Beurer",
        stock: 15),
  ];
}