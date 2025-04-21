import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaiterPickupScreen extends StatefulWidget {
  const WaiterPickupScreen({super.key});

  @override
  State<WaiterPickupScreen> createState() => _WaiterPickupScreenState();
}

class _WaiterPickupScreenState extends State<WaiterPickupScreen> {
  final Map<String, bool> _expandedOrders = {};

  Future<void> _markAsDelivered(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'delivered',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as delivered')),
      );
    } catch (e) {
      print('Error marking order as delivered: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking order as delivered: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'ready')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error in WaiterPickupScreen: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return const Center(child: Text('No orders ready for pickup'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final isExpanded = _expandedOrders[orderId] ?? false;

              final orderData = order.data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
              final total = orderData['total'] as double? ?? 0.0;
              final status = orderData['status'] as String? ?? 'Unknown';
              final tableNumber = orderData['tableNumber'] as String? ?? 'Not assigned';
              final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate().toString() ?? 'Unknown';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Order #$orderId'),
                    subtitle: Text('Table: $tableNumber | Total: \Rs. ${total.toStringAsFixed(2)}'),
                    trailing: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onTap: () {
                      setState(() {
                        _expandedOrders[orderId] = !isExpanded;
                      });
                    },
                  ),
                  if (isExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: $status', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Table No: $tableNumber', style: const TextStyle(fontSize: 16)),
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
                                    final itemIndex = entry.key;
                                    final item = entry.value;
                                    final foodItem = item['foodItem'] as Map<String, dynamic>? ?? {};
                                    final name = foodItem['name'] as String? ?? 'Unknown Item';
                                    final quantity = item['quantity'] as int? ?? 0;
                                    final totalPrice = item['totalPrice'] as double? ?? 0.0;
                                    final addons = List<Map<String, dynamic>>.from(item['addons'] ?? []);
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: ListTile(
                                        title: Text('$name'),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                           
                                            Text('Quantity: $quantity'),
                                            Text('Total Price: \RS. ${totalPrice.toStringAsFixed(2)}'),
                                            if (addons.isNotEmpty) ...[
                                              const Text('Addons:', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ...addons.map((addon) {
                                                final addonName = addon['name'] as String? ?? 'Unknown';
                                                final addonPrice = addon['price'] as double? ?? 0.0;
                                                return Text('$addonName: \$${addonPrice.toStringAsFixed(2)}');
                                              }),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: status != 'ready'
                                    ? null
                                    : () => _markAsDelivered(orderId),
                                child: const Text('Mark as Delivered'),
                              ),
                            ],
                          ),
                        ],
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