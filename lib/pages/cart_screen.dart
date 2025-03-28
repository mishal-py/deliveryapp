import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newapp/models/cart_model.dart';
import 'package:newapp/pages/home_page.dart';

const double deliveryCharge = 150.00;
class CartScreen extends StatelessWidget {
  
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('Your Cart'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_sharp),
            onPressed: () => Provider.of<CartModel>(context, listen: false).clearCart(),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Dismissible(
                      key: Key(item.hashCode.toString()),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) => cart.removeItem(index),
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          leading: Image.asset(
                            item.food.imagepath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.food.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nrs.${item.totalPrice.toStringAsFixed(2)}'),
                              if (item.selectedAddons.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add-ons:',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 4,
                                      children: item.selectedAddons.map((addon) => Text(
                                        '• ${addon.name}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    cart.decrementQuantity(index);
                                  } else {
                                    cart.removeItem(index);
                                  }
                                },
                              ),
                              Text(item.quantity.toString()),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => cart.incrementQuantity(index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Charge:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Nrs.$deliveryCharge',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Nrs.${(cart.totalPrice + deliveryCharge).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                
                  },
                  child: const Text('Proceed to Checkout'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}