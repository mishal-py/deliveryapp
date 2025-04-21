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
        title: const Text('Waiter Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary, // Primary color
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16), // Slightly rounded bottom corners
          ),
        ),
        actions: [
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
            padding: const EdgeInsets.all(8), // Add padding around the list
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              print('Order ${order.id}: ${order.data()}');
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Spacing between boxes
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary, // Secondary color
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: ListTile(
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
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: 'New Order',
            tooltip: 'Take New Order',
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<QuerySnapshot>(
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
                  clipBehavior: Clip.none, // Allow badge to overflow
                  children: [
                    const Icon(Icons.notifications),
                    if (readyOrdersCount > 0)
                      Positioned(
                        right: -8,
                        top: -8,
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
            label: 'Pickup Orders',
            tooltip: 'Pickup Orders',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            print('Navigating to WaiterOrderScreen');
            Navigator.pushNamed(context, '/waiter_order');
          } else if (index == 1) {
            print('Navigating to WaiterPickupScreen');
            Navigator.pushNamed(context, '/waiter_pickup');
          }
        },
      ),
    );
  }
}