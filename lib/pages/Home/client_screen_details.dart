import 'package:flutter/material.dart';
import 'package:newapp/models/foods.dart';

class ClientScreenDetails extends StatefulWidget {
  final FoodItem foodItem;
  final String categoryId;

  const ClientScreenDetails({super.key, required this.foodItem, required this.categoryId});

  @override
  State<ClientScreenDetails> createState() => _ClientScreenDetailsState();
}

class _ClientScreenDetailsState extends State<ClientScreenDetails> {
  String _selectedSize = '380g';
  final List<String> _sizes = ['380g', '480g', '560g'];
  List<Addon> _selectedAddons = [];
  int _quantity = 1;
  double _basePrice = 0.0;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _basePrice = widget.foodItem.price;
    _totalPrice = _basePrice;
  }

  void _updateTotalPrice() {
    double addonPrice = _selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    setState(() {
      _totalPrice = (_basePrice + addonPrice) * _quantity;
    });
  }

  void _addToCart() {
    final addons = _selectedAddons.map((addon) {
      return {
        'name': addon.name,
        'price': addon.price,
      };
    }).toList();

    final cartItem = {
      'foodId': widget.foodItem.id,
      'name': widget.foodItem.name,
      'price': widget.foodItem.price,
      'quantity': _quantity,
      'categoryId': widget.categoryId,
      'size': _selectedSize,
      'addons': addons,
      'totalPrice': _totalPrice,
    };
    Navigator.pop(context, cartItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            widget.foodItem.photoUrl != null
                ? Image.network(widget.foodItem.photoUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.fastfood, size: 50),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Description
                  Text(
                    widget.foodItem.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.foodItem.description),
                  const SizedBox(height: 16),
                  // Size Selection
                  const Text('Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: _sizes.map((size) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChoiceChip(
                          label: Text(size),
                          selected: _selectedSize == size,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Addons
                  const Text('Build Your Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: widget.foodItem.addons.map((addon) {
                      final isSelected = _selectedAddons.contains(addon);
                      return ChoiceChip(
                        label: Text('${addon.name} (\Rs. ${addon.price})'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAddons.add(addon);
                            } else {
                              _selectedAddons.remove(addon);
                            }
                            _updateTotalPrice();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text('\Rs. ${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _quantity > 1
                  ? () {
                      setState(() {
                        _quantity--;
                        _updateTotalPrice();
                      });
                    }
                  : null,
            ),
            Text('$_quantity'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _quantity++;
                  _updateTotalPrice();
                });
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add to Order'),
            ),
          ],
        ),
      ),
    );
  }
}