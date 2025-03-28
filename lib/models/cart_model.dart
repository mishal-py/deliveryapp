import 'package:flutter/foundation.dart';
import 'package:newapp/models/cart_item.dart';

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  
  double get totalPrice => _items.fold(
    0, 
    (sum, item) => sum + item.totalPrice
  );

  void addItem(CartItem newItem) {
    // Check for existing item
    final existingIndex = _items.indexWhere((item) => item.isSameItem(newItem));
    
    if (existingIndex != -1) {
      // Increase quantity if exists
      _items[existingIndex].quantity += newItem.quantity;
    } else {
      // Add new item
      _items.add(newItem);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void incrementQuantity(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
    }
  }
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}