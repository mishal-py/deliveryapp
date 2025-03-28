import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newapp/models/foods.dart';
import 'package:newapp/models/cart_item.dart';
import 'package:newapp/models/cart_model.dart';
import 'package:newapp/components/custom_button.dart';
import 'package:newapp/pages/cart_screen.dart';

class FoodPage extends StatefulWidget {
  final Foods foods;

  const FoodPage({
    super.key,
    required this.foods,
  });

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final Set<Addon> _selectedAddons = {};
  int _quantity = 1;

  void _addToCart(BuildContext context) {
    final cartItem = CartItem(
      food: widget.foods,
      selectedAddons: _selectedAddons.toList(),
      quantity: _quantity, // Added quantity parameter
    );

    Provider.of<CartModel>(context, listen: false).addItem(cartItem);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    );
  }

  double _calculateTotalPrice() {
    return (widget.foods.price + 
           _selectedAddons.fold(0, (sum, addon) => sum + addon.price)) * 
           _quantity; // Added quantity multiplier
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                flexibleSpace: Stack(
                  children: [
                    Image.asset(
                      widget.foods.imagepath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(25),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.foods.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Nrs.${widget.foods.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.foods.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Add-ons",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final addon = widget.foods.availableAddons[index];
                      return CheckboxListTile(
                        title: Text(addon.name),
                        subtitle: Text("Nrs.${addon.price.toStringAsFixed(2)}"),
                        value: _selectedAddons.contains(addon),
                        onChanged: (value) {
                          setState(() {
                            value! 
                              ? _selectedAddons.add(addon)
                              : _selectedAddons.remove(addon);
                          });
                        },
                      );
                    },
                    childCount: widget.foods.availableAddons.length,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 25,
            left: 25,
            right: 25,
            child: Column(
              children: [
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                      ),
                      Text(
                        _quantity.toString(),
                        style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: "Add to Cart (Nrs.${_calculateTotalPrice().toStringAsFixed(2)})",
                  onTap: () => _addToCart(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}