import 'package:flutter/material.dart';
import 'package:newapp/models/foods.dart';

class ClientOrderScreen extends StatefulWidget {
  final FoodItem foodItem;

  const ClientOrderScreen({super.key, required this.foodItem});

  @override
  State<ClientOrderScreen> createState() => _ClientOrderScreenState();
}

class _ClientOrderScreenState extends State<ClientOrderScreen> {
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
    final cartItem = {
      'foodItem': widget.foodItem,
      'addons': _selectedAddons,
      'quantity': _quantity,
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
                  const SizedBox(height: 16),
                  // Addons
                  const Text('Build Your Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text('Select Addons', style: TextStyle(fontSize: 12,)),
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