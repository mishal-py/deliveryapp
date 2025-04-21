import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newapp/models/cart_model.dart';
import 'package:newapp/models/foods.dart';
import 'package:newapp/pages/menu_management/menu_repository.dart';
import 'client_screen_details.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key});

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  final MenuRepository _repository = MenuRepository();
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
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
          const SizedBox(height: 16),
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
          // Offer Food Items
          Expanded(
            child: _selectedCategoryId == null
                ? const Center(child: Text('Select a category to view offers'))
                : StreamBuilder<List<FoodItem>>(
                    stream: _repository.getFoodItems(_selectedCategoryId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        print('Error fetching offer items: ${snapshot.error}');
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No offers in this category'));
                      }
                      // Filter for items with isSpecialOffer == true
                      final offerItems = snapshot.data!.where((item) => item.isSpecialOffer).toList();
                      if (offerItems.isEmpty) {
                        return const Center(child: Text('No special offers available'));
                      }
                      return ListView.builder(
                        itemCount: offerItems.length,
                        itemBuilder: (context, index) {
                          final foodItem = offerItems[index];
                          return ListTile(
                            leading: foodItem.photoUrl != null
                                ? Image.network(
                                    foodItem.photoUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.fastfood),
                                  )
                                : const Icon(Icons.fastfood),
                            title: Text(foodItem.name),
                            subtitle: Text('\Rs. ${foodItem.price.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientScreenDetails(
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