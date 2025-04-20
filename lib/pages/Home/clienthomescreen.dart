import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newapp/models/cart_model.dart';
import 'package:newapp/pages/menu_management/menu_repository.dart';
import '../../models/foods.dart';
import 'client_screen_details.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final MenuRepository _repository = MenuRepository();
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, '/client_cart');
                },
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Consumer<CartModel>(
                  builder: (context, cart, child) {
                    final itemCount = cart.items.length;
                    return itemCount > 0
                        ? Container(
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
                              '$itemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ],
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
                            trailing: IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientScreenDetails( // Updated to ClientScreenDetails
                                      foodItem: foodItem,
                                      categoryId: _selectedCategoryId!,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  final cart = Provider.of<CartModel>(context, listen: false);
                                  cart.addItem(
                                    result['foodId'],
                                    result['name'],
                                    result['price'],
                                    result['quantity'],
                                    categoryId: result['categoryId'],
                                    size: result['size'],
                                    addons: result['addons'],
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${result['name']} added to cart')),
                                  );
                                }
                              },
                            ),
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