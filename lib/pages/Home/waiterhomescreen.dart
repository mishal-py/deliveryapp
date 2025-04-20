import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaiterHomeScreen extends StatelessWidget {
  const WaiterHomeScreen({super.key});

  // Function to handle logout
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully');
      // Navigate to login screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // This clears the navigation stack
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
        title: const Text('Waiter Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              print('Navigating to WaiterOrderScreen');
              Navigator.pushNamed(context, '/waiter_order');
            },
            tooltip: 'Take New Order',
          ),
          // Notification Icon with Badge
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('status', isEqualTo: 'ready')
                .snapshots(),
            builder: (context, snapshot) {
              int readyOrdersCount = 0;
              if (snapshot.hasData) {
                readyOrdersCount = snapshot.data!.docs.length;
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      print('Navigating to WaiterPickupScreen');
                      Navigator.pushNamed(context, '/waiter_pickup');
                    },
                    tooltip: 'Pickup Orders',
                  ),
                  if (readyOrdersCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$readyOrdersCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error in WaiterHomeScreen: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            print('Waiting for data...');
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          print('Number of orders fetched: ${orders.length}');
          if (orders.isEmpty) {
            return const Center(child: Text('No pending orders'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              print('Order ${order.id}: ${order.data()}');
              return ListTile(
                title: Text('Order #${order.id}'),
                subtitle: Text('Total: \Rs. ${order['total'].toStringAsFixed(2)}'),
                onTap: () {
                  print('Navigating to WaiterOrderDetailsScreen with order ID: ${order.id}');
                  try {
                    Navigator.pushNamed(
                      context,
                      '/waiter_order_details',
                      arguments: order.id,
                    ).then((_) {
                      print('Returned from WaiterOrderDetailsScreen');
                    });
                  } catch (e) {
                    print('Navigation error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigation error: $e')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}