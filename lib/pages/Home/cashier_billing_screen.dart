import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class CashierBillingScreen extends StatefulWidget {
  const CashierBillingScreen({super.key});

  @override
  State<CashierBillingScreen> createState() => _CashierBillingScreenState();
}

class _CashierBillingScreenState extends State<CashierBillingScreen> {
  String? _selectedTableNumber;
  final Map<String, bool> _expandedOrders = {};

  Future<void> _markAsPaid(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'completed',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment completed')),
      );
    } catch (e) {
      print('Error marking order as paid: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking order as paid: $e')),
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
    // Calculate the start and end of the current day dynamically
    DateTime now = DateTime(2025, 4, 20); // Current date as per system instructions
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day + 1);
    String formattedDate = DateFormat('MMMM d, yyyy').format(now); // Format: "April 20, 2025"

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier Billing'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown to select table
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isEqualTo: 'delivered')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final tableNumbers = snapshot.data!.docs
                    .map((doc) => (doc.data() as Map<String, dynamic>)['tableNumber'] as String?)
                    .where((table) => table != null)
                    .toSet()
                    .toList();
                return DropdownButton<String>(
                  hint: const Text('Select Table'),
                  value: _selectedTableNumber,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Tables')),
                    ...tableNumbers.map((table) => DropdownMenuItem(
                          value: table,
                          child: Text('Table $table'),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTableNumber = value;
                    });
                  },
                );
              },
            ),
          ),
          // Daily Collection Summary
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('status', isEqualTo: 'completed')
                .where('createdAt',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
                .where('createdAt',
                    isLessThan: Timestamp.fromDate(endOfDay))
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final completedOrders = snapshot.data!.docs;
              final dailyTotal = completedOrders.fold<double>(
                  0.0,
                  (sum, doc) =>
                      sum + ((doc.data() as Map<String, dynamic>)['total'] as double? ?? 0.0));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Daily Collection ($formattedDate): \Rs. ${dailyTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isEqualTo: 'delivered')
                  .where('tableNumber',
                      isEqualTo: _selectedTableNumber)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error in CashierBillingScreen: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data!.docs;
                if (orders.isEmpty) {
                  return const Center(child: Text('No delivered orders for this table'));
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
                    final createdAt =
                        (orderData['createdAt'] as Timestamp?)?.toDate().toString() ?? 'Unknown';

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
                                const Text('Items:',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                items.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text('No items in this order'),
                                      )
                                    : Column(
                                        children: items.asMap().entries.map((entry) {
                                          final itemIndex = entry.key;
                                          final item = entry.value;
                                          final foodItem =
                                              item['foodItem'] as Map<String, dynamic>? ?? {};
                                          final name = foodItem['name'] as String? ?? 'Unknown Item';
                                          final quantity = item['quantity'] as int? ?? 0;
                                          final totalPrice = item['totalPrice'] as double? ?? 0.0;
                                          final addons =
                                              List<Map<String, dynamic>>.from(item['addons'] ?? []);
                                          return Card(
                                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: ListTile(
                                              title: Text('$name'),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Quantity: $quantity'),
                                                  Text(
                                                      'Total Price: \Rs. ${totalPrice.toStringAsFixed(2)}'),
                                                  if (addons.isNotEmpty) ...[
                                                    const Text('Addons:',
                                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ...addons.map((addon) {
                                                      final addonName =
                                                          addon['name'] as String? ?? 'Unknown';
                                                      final addonPrice =
                                                          addon['price'] as double? ?? 0.0;
                                                      return Text(
                                                          '$addonName: \Rs. ${addonPrice.toStringAsFixed(2)}');
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
                                      onPressed: status != 'delivered'
                                          ? null
                                          : () => _markAsPaid(orderId),
                                      child: const Text('Mark as Paid'),
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
          ),
        ],
      ),
    );
  }
}