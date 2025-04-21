import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newapp/models/cart_model.dart';
import 'package:newapp/pages/menu_management/menu_repository.dart';

class ClientCartScreen extends StatefulWidget {
  const ClientCartScreen({super.key});

  @override
  State<ClientCartScreen> createState() => _ClientCartScreenState();
}

class _ClientCartScreenState extends State<ClientCartScreen> {
  final MenuRepository _repository = MenuRepository();
  String? _selectedCategoryId;
  bool _isWithinPokhara = true;
  final double _deliveryFee = 150.0;

  Future<Map<String, String>> _fetchCategoryNames() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return {
      for (var doc in snapshot.docs) doc.id: doc['name'] as String,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
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
                                    
                                    Text('Quantity: ${item.quantity}'),
                                    if (item.addons.isNotEmpty)
                                      Text('Addons: ${item.addons.map((addon) => addon['name']).join(', ')}'),
                                    Text('Price: \Rs. ${item.totalPrice.toStringAsFixed(2)}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        final cartIndex = cartItems.indexOf(item);
                                        cart.updateQuantity(cartIndex, item.quantity - 1);
                                        if (item.quantity <= 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${item.name} removed from cart')),
                                          );
                                        }
                                      },
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        final cartIndex = cartItems.indexOf(item);
                                        cart.updateQuantity(cartIndex, item.quantity + 1);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        final cartIndex = cartItems.indexOf(item);
                                        cart.removeItem(cartIndex);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${item.name} removed from cart')),
                                        );
                                      },
                                      tooltip: 'Remove Item',
                                    ),
                                  ],
                                ),
                              );
                            },
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
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/client_checkout');
                    },
              child: const Text('Proceed to Checkout'),
            );
          },
        ),
      ),
    );
  }
}