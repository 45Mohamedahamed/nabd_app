import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // حساب إجمالي سعر هذا العنصر (السعر × الكمية)
  double get totalItemPrice => product.price * quantity;

  // تحويل لـ Map لتخزينه في الفايربيز لاحقاً كجزء من الطلب
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'price': product.price,
      'quantity': quantity,
      'total': totalItemPrice,
    };
  }
}