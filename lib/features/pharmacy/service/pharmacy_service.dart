import 'package:cloud_firestore/cloud_firestore.dart';
// 👇 انتبه للمسارات هنا: نخرج من services (..) ثم ندخل model
import '../model/product_model.dart';
import '../model/pharmacy_data.dart';
import '../model/order_model.dart'; // استدعاء موديل الطلبات الجديد

class PharmacyService {
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');
      // أضف هذه الدالة داخل كلاس PharmacyService
Stream<List<OrderModel>> getMyOrders(String userId) {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true) // الأحدث أولاً
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList());
}
  // 1️⃣ دالة جلب البيانات (Download)
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _productsRef
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());

  }

  // 2️⃣ دالة رفع البيانات (Upload)
  Future<void> uploadAllMockData() async {
    final batch = FirebaseFirestore.instance.batch();

    // تجميع البيانات من الملف الثابت
    List<ProductModel> allProducts = [
      ...PharmacyData.medicines,
      ...PharmacyData.vitamins,
      ...PharmacyData.personalCare,
      ...PharmacyData.equipment,
    ];

    for (var product in allProducts) {
      final docRef = _productsRef.doc(product.id);
      batch.set(docRef, product.toMap());
    }

    await batch.commit();
    print("✅ تم رفع جميع المنتجات (${allProducts.length}) بنجاح!");
  }
}