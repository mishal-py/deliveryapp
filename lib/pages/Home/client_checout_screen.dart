import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newapp/models/cart_model.dart';

class ClientCheckoutScreen extends StatefulWidget {
  const ClientCheckoutScreen({super.key});

  @override
  State<ClientCheckoutScreen> createState() => _ClientCheckoutScreenState();
}

class _ClientCheckoutScreenState extends State<ClientCheckoutScreen> {
  bool _isWithinPokhara = true;
  final double _deliveryFee = 150.0;
  String? _selectedCategoryId;
  final _addressController = TextEditingController();

  Future<Map<String, String>> _fetchCategoryNames() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return {
      for (var doc in snapshot.docs) doc.id: doc['name'] as String,
    };
  }

  Future<void> _confirmOrder(BuildContext context, List<CartItem> cartItems) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Proceed with payment and place your order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
      ),
      ],
      ),
    );

    if (confirm != true) return;

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful! Placing order...')),
    );

    try {
      final subtotal = cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
      final total = subtotal + (_isWithinPokhara ? _deliveryFee : 0);

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'role': 'client',
        'tableNumber': null,
        'items': cartItems.map((item) {
          return {
            'foodItem': {
              'id': item.foodId,
              'name': item.name,
              'price': item.price,
              'categoryId': item.categoryId,
            },
            'size': item.size ?? 'N/A',
            'addons': item.addons,
            'quantity': item.quantity,
            'totalPrice': item.totalPrice,
          };
        }).toList(),
        'status': 'pending',
        'subtotal': subtotal,
        'deliveryFee': _isWithinPokhara ? _deliveryFee : 0,
        'total': total,
        'deliveryLocation': _isWithinPokhara ? 'Pokhara' : 'Outside Pokhara',
        'deliveryAddress': _addressController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final cart = Provider.of<CartModel>(context, listen: false);
      cart.clear();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully')),
        );
        Navigator.popUntil(context, ModalRoute.withName('/client_home'));
      }
    } catch (e) {
      print('Error placing order: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          final cartItems = cart.items;
          if (cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return FutureBuilder<Map<String, String>>(
            future: _fetchCategoryNames(),
            builder: (context, categorySnapshot) {
              if (categorySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (categorySnapshot.hasError) {
                return Center(child: Text('Error: ${categorySnapshot.error}'));
              }
              if (!categorySnapshot.hasData || categorySnapshot.data!.isEmpty) {
                return const Center(child: Text('No categories available'));
              }

              final categoryNames = categorySnapshot.data!;
              final categoryIds = cartItems.map((item) => item.categoryId).toSet().toList();

              final filteredItems = _selectedCategoryId == null
                  ? cartItems
                  : cartItems.where((item) => item.categoryId == _selectedCategoryId).toList();

              final subtotal = cart.total;
              final total = subtotal + (_isWithinPokhara ? _deliveryFee : 0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categoryIds.map((categoryId) {
                        final categoryName = categoryNames[categoryId] ?? 'Unknown Category';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ChoiceChip(
                            label: Text(categoryName),
                            selected: _selectedCategoryId == categoryId,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategoryId = selected ? categoryId : null;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? const Center(child: Text('No items in this category'))
                        : ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return ListTile(
                                title: Text(item.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Size: ${item.size ?? 'N/A'}'),
                                    Text('Quantity: ${item.quantity}'),
                                    if (item.addons.isNotEmpty)
                                      Text('Addons: ${item.addons.map((addon) => addon['name']).join(', ')}'),
                                    Text('Price: \Rs. ${item.totalPrice.toStringAsFixed(2)}'),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Delivery in Pokhara?',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _isWithinPokhara,
                          onChanged: (value) {
                            setState(() {
                              _isWithinPokhara = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subtotal: \Rs. ${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_isWithinPokhara)
                          Text(
                            'Delivery Fee (Pokhara): \Rs. ${_deliveryFee.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        Text(
                          'Total: \Rs. ${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CartModel>(
          builder: (context, cart, child) {
            return ElevatedButton(
              onPressed: cart.items.isEmpty ? null : () => _confirmOrder(context, cart.items),
              child: const Text('Confirm Order'),
            );
          },
        ),
      ),
    );
  }
}