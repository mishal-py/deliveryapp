import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class WaiterApproveOrderScreen extends StatelessWidget {
  const WaiterApproveOrderScreen({super.key});

  Future<void> _approveOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'approved',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Online Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('role', isEqualTo: 'client')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No online orders to approve'));
          }
          final orders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final items = (order['items'] as List).map((item) => item as Map<String, dynamic>).toList();
              return ListTile(
                title: Text('Order #${orders[index].id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: \Rs. ${order['total'].toStringAsFixed(2)}'),
                    Text('Items: ${items.length}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _approveOrder(orders[index].id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order approved')),
                      );
                    }
                  },
                  child: const Text('Approve'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}