import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final double totalAmount;
  final String status; // pending, shipping, delivered
  final DateTime createdAt;
  final List items;

  OrderModel({
    required this.orderId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      items: map['items'] ?? [],
    );
  }
}