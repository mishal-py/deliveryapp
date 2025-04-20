import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newapp/models/foods.dart';
import 'package:newapp/pages/menu_management/menu_repository.dart';
import 'clientorderscreen.dart';

class WaiterOrderScreen extends StatefulWidget {
  const WaiterOrderScreen({super.key});

  @override
  State<WaiterOrderScreen> createState() => _WaiterOrderScreenState();
}

class _WaiterOrderScreenState extends State<WaiterOrderScreen> {
  final MenuRepository _repository = MenuRepository();
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _orderItems = [];
  String? _selectedTableNumber; // To store the selected table number

  void _addItemToOrder(Map<String, dynamic> item) {
    // Convert addons to maps if they are Addon objects
    final addons = (item['addons'] as List<dynamic>).map((addon) {
      if (addon is Addon) {
        return addon.toMap();
      } else if (addon is Map<String, dynamic>) {
        return addon;
      } else {
        throw Exception('Unexpected addon type: ${addon.runtimeType}');
      }
    }).toList();

    // Create a new item with converted addons
    final updatedItem = Map<String, dynamic>.from(item);
    updatedItem['addons'] = addons;

    setState(() {
      _orderItems.add(updatedItem);
    });
  }

  // Function to remove an item from the order
  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed from order')),
    );
  }

  Future<void> _submitOrder() async {
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items to the order')),
      );
      return;
    }

    if (_selectedTableNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a table number')),
      );
      return;
    }

    try {
      final total = _orderItems.fold<double>(0, (sum, item) => sum + item['totalPrice']);
      print('Submitting order with items: $_orderItems');
      print('Table Number: $_selectedTableNumber');
      print('Total: $total');
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'role': 'waiter',
        'tableNumber': _selectedTableNumber, // Add table number to the order
        'items': _orderItems.map((item) {
          return {
            'foodItem': (item['foodItem'] as FoodItem).toMap(),
            'size': item['size'],
            'addons': item['addons'], // Already a list of maps
            'quantity': item['quantity'],
            'totalPrice': item['totalPrice'],
          };
        }).toList(),
        'status': 'pending',
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order submitted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error submitting order: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Order'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          StreamBuilder<List<MenuCategory>>(
            stream: _repository.getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print('Error fetching categories: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No categories available'));
              }
              final categories = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category.id : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Food Items
          Expanded(
            child: _selectedCategoryId == null
                ? const Center(child: Text('Select a category to view items'))
                : StreamBuilder<List<FoodItem>>(
                    stream: _repository.getFoodItems(_selectedCategoryId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        print('Error fetching food items for category $_selectedCategoryId: ${snapshot.error}');
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No items in this category'));
                      }
                      final foodItems = snapshot.data!;
                      return ListView.builder(
                        itemCount: foodItems.length,
                        itemBuilder: (context, index) {
                          final foodItem = foodItems[index];
                          return ListTile(
                            leading: foodItem.photoUrl != null
                                ? Image.network(foodItem.photoUrl!, width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.fastfood),
                            title: Text(foodItem.name),
                            subtitle: Text('\Rs. ${foodItem.price.toStringAsFixed(2)}'),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClientOrderScreen(foodItem: foodItem),
                                ),
                              );
                              if (result != null) {
                                _addItemToOrder(result);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
          // Table Number Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Table No: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Select Table'),
                  value: _selectedTableNumber,
                  items: List.generate(20, (index) => (index + 1).toString())
                      .map((table) => DropdownMenuItem(
                            value: table,
                            child: Text('Table $table'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTableNumber = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Selected Items
          if (_orderItems.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Selected Items:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 150, // Fixed height for the selected items list
              child: ListView.builder(
                itemCount: _orderItems.length,
                itemBuilder: (context, index) {
                  final item = _orderItems[index];
                  final foodItem = item['foodItem'] as FoodItem;
                  final size = item['size'] as String? ?? 'N/A';
                  final quantity = item['quantity'] as int? ?? 0;
                  final totalPrice = item['totalPrice'] as double? ?? 0.0;
                  final addons = List<Map<String, dynamic>>.from(item['addons'] ?? []);
                  return ListTile(
                    title: Text(foodItem.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Size: $size'),
                        Text('Quantity: $quantity'),
                        if (addons.isNotEmpty)
                          Text(
                            'Addons: ${addons.map((addon) => addon['name']).join(', ')}',
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\Rs. ${totalPrice.toStringAsFixed(2)}'),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                          tooltip: 'Remove Item',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              'Items: ${_orderItems.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitOrder,
              child: const Text('Submit Order'),
            ),
          ],
        ),
      ),
    );
  }
}