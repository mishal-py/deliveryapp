import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KitchenOrderScreen extends StatefulWidget {
  const KitchenOrderScreen({super.key});

  @override
  State<KitchenOrderScreen> createState() => _KitchenOrderScreenState();
}

class _KitchenOrderScreenState extends State<KitchenOrderScreen> {
  // Map to track which orders are expanded
  final Map<String, bool> _expandedOrders = {};

  Future<void> _markAsReady(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'ready',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as ready')),
      );
    } catch (e) {
      print('Error marking order as ready: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking order as ready: $e')),
      );
    }
  }
  
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully');
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Orders'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'approved')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error in KitchenOrderScreen: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return const Center(child: Text('No approved orders'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order.id;
              final isExpanded = _expandedOrders[orderId] ?? false;

              // Order data
              final orderData = order.data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
              final total = orderData['total'] as double? ?? 0.0;
              final status = orderData['status'] as String? ?? 'Unknown';
              final userId = orderData['userId'] as String? ?? 'Unknown';
              final role = orderData['role'] as String? ?? 'Unknown';
              final tableNumber = orderData['tableNumber'] as String? ?? 'Not assigned'; // Add table number
              final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate().toString() ?? 'Unknown';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Order #$orderId'),
                    subtitle: Text('Table: $tableNumber | Total: \Rs. ${total.toStringAsFixed(2)}'), // Show table number in subtitle
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
                          Text('Table No: $tableNumber', style: const TextStyle(fontSize: 16)), // Display table number
                          const SizedBox(height: 8),
                          Text('User ID: $userId', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Placed by: $role', style: const TextStyle(fontSize: 16)),
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
                                                return Text('$addonName: \Rs. ${addonPrice.toStringAsFixed(2)}');
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
                                onPressed: status != 'approved'
                                    ? null
                                    : () => _markAsReady(orderId),
                                child: const Text('Mark as Ready'),
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