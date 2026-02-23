class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl;
  final bool requiresPrescription;
  final String manufacturer;
  final String expiryDate;
  int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.requiresPrescription = false,
    this.manufacturer = "Unknown",
    this.expiryDate = "2026",
    this.stock = 10,
  });

  // 👇 تحويل البيانات لـ Map لإرسالها للفايربيز
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'requiresPrescription': requiresPrescription,
      'manufacturer': manufacturer,
      'expiryDate': expiryDate,
      'stock': stock,
    };
  }

  // 👇 استقبال البيانات من الفايربيز
  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      // التحويل لـ double ضروري لتجنب الأخطاء
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      requiresPrescription: map['requiresPrescription'] ?? false,
      manufacturer: map['manufacturer'] ?? 'Unknown',
      expiryDate: map['expiryDate'] ?? '',
      stock: (map['stock'] ?? 0).toInt(),
    );
  }
}