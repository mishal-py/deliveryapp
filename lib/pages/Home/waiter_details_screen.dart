import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaiterOrderDetailsScreen extends StatelessWidget {
  const WaiterOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the order ID from the route arguments
    final String? orderId = ModalRoute.of(context)?.settings.arguments as String?;

    if (orderId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Error: No order ID provided')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$orderId'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error in WaiterOrderDetailsScreen: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data!;
          if (!order.exists) {
            return const Center(child: Text('Order not found'));
          }

          final orderData = order.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
          final total = orderData['total'] as double? ?? 0.0;
          final status = orderData['status'] as String? ?? 'Unknown';
          final userId = orderData['userId'] as String? ?? 'Unknown';
          final role = orderData['role'] as String? ?? 'Unknown';
          final tableNumber = orderData['tableNumber'] as String? ?? 'Not assigned'; // Add table number
          final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate().toString() ?? 'Unknown';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: $status', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Table No: $tableNumber', style: const TextStyle(fontSize: 16)), // Display table number
                const SizedBox(height: 8),
                Text('User ID: $userId', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Placed by: $role', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Created At: $createdAt', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('No items in this order'))
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final foodItem = item['foodItem'] as Map<String, dynamic>? ?? {};
                            final name = foodItem['name'] as String? ?? 'Unknown Item';
                            final size = item['size'] as String? ?? 'N/A';
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
                                    Text('Size: $size'),
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
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Text('Total: \Rs. ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: status != 'pending'
                        ? null
                        : () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .update({'status': 'approved'});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order approved')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error approving order: $e')),
                              );
                            }
                          },
                    child: const Text('Approve Order'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}