import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product_model.dart';
import '../model/cart_model.dart';

class CartProvider extends ChangeNotifier {
  // القائمة الخاصة بالعناصر في السلة
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // 1. حساب إجمالي الفاتورة
  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalItemPrice);
  }

  // 2. دالة إضافة للسلة (Add to Cart)
  void addToCart(ProductModel product) {
    // نتأكد هل المنتج موجود أصلاً؟
    int index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // لو موجود، زود الكمية بس
      _items[index].quantity++;
    } else {
      // لو جديد، ضيفه للقائمة
      _items.add(CartItem(product: product));
    }
    notifyListeners(); // تنبيه الشاشات لتحديث الواجهة
  }

  // 3. تقليل الكمية أو الحذف
  void removeFromCart(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  // 4. حذف العنصر نهائياً
  void deleteItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  // 5. تنظيف السلة بعد الطلب
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // 🚀 6. إرسال الطلب للفايربيز (Place Order)
  Future<void> placeOrder(String userId, String address) async {
    if (_items.isEmpty) return;

    final orderRef = FirebaseFirestore.instance.collection('orders').doc();

    await orderRef.set({
      'orderId': orderRef.id,
      'userId': userId, // يمكن جلبه من FirebaseAuth
      'address': address,
      'status': 'pending', // حالة الطلب: قيد الانتظار
      'totalAmount': totalPrice,
      'createdAt': FieldValue.serverTimestamp(),
      'items': _items.map((e) => e.toMap()).toList(), // تحويل القائمة لـ JSON
    });

    clearCart(); // تفريغ السلة بعد النجاح
  }
}