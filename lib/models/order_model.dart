import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final String role;
  final String tableNumber;
  final List<Map<String, dynamic>> items;
  final String status;
  final double total;
  final Timestamp createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.role,
    required this.tableNumber,
    required this.items,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'tableNumber': tableNumber,
      'items': items,
      'status': status,
      'total': total,
      'createdAt': createdAt,
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      role: map['role'] ?? '',
      tableNumber: map['tableNumber'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      status: map['status'] ?? 'pending',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}