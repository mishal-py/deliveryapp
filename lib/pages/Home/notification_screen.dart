import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientNotificationScreen extends StatefulWidget {
  const ClientNotificationScreen({super.key});

  @override
  State<ClientNotificationScreen> createState() => _ClientNotificationScreenState();
}

class _ClientNotificationScreenState extends State<ClientNotificationScreen> {
  final Map<String, bool> _expandedOrders = {};

  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Your order has been placed and is awaiting approval.';
      case 'approved':
        return 'Your order has been approved and is being prepared.';
      case 'ready':
        return 'Your order is ready for pickup or delivery.';
      case 'delivered':
        return 'Your order has been delivered. Enjoy!';
      default:
        return 'Order status: $status';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        body: const Center(child: Text('Please log in to view notifications')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error fetching notifications: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load notifications'),
                  const SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications available'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final isExpanded = _expandedOrders[orderId] ?? false;

              // Order data
              final orderData = order.data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
              final total = orderData['total'] as double? ?? 0.0;
              final status = orderData['status'] as String? ?? 'pending';
              final tableNumber = orderData['tableNumber'] as String? ?? 'Not assigned';
              final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate().toString() ?? 'Unknown';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text('Order #${orderId.substring(0, 8)}'),
                      subtitle: Text(_getStatusMessage(status)),
                      trailing: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      onTap: () {
                        setState(() {
                          _expandedOrders[orderId] = !isExpanded;
                        });
                      },
                    ),
                  ),
                  if (isExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Table No: $tableNumber', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Total: \Rs. ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Created At: $createdAt', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 16),
                            const Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            items.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text('No items in this order'),
                                  )
                                : Column(
                                    children: items.asMap().entries.map((entry) {
                                      final item = entry.value;
                                      final foodItem = item['foodItem'] as Map<String, dynamic>? ?? {};
                                      final name = foodItem['name'] as String? ?? 'Unknown Item';
                                      final quantity = item['quantity'] as int? ?? 0;
                                      final totalPrice = item['totalPrice'] as double? ?? 0.0;
                                      final addons = List<Map<String, dynamic>>.from(item['addons'] ?? []);
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: ListTile(
                                          title: Text(name),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Quantity: $quantity'),
                                              Text('Total Price: \Rs. ${totalPrice.toStringAsFixed(2)}'),
                                              if (addons.isNotEmpty) ...[
                                                const Text('Addons:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                ...addons.map((addon) {
                                                  final addonName = addon['name'] as String? ?? 'Unknown';
                                                  final addonPrice = addon['price'] as double? ?? 0.0;
                                                  return Text('$addonName: \Rs. ${addonPrice.toStringAsFixed(2)}');
                                                }),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}