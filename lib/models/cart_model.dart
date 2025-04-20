import 'package:flutter/foundation.dart';

class CartItem {
  final String foodId;
  final String name;
  final double price;
  int quantity;
  final String categoryId;
  final String? size;
  final List<Map<String, dynamic>> addons;

  CartItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.categoryId,
    this.size,
    this.addons = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'size': size,
      'addons': addons,
    };
  }

  double get totalPrice {
    double total = price * quantity;
    if (addons.isNotEmpty) {
      total += addons.fold(0.0, (sum, addon) => sum + (addon['price'] as double)) * quantity;
    }
    return total;
  }
}

class CartModel with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get total => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(String foodId, String name, double price, int quantity, {required String categoryId, String? size, List<Map<String, dynamic>>? addons}) {
    final existingItemIndex = _items.indexWhere((item) => item.foodId == foodId && item.size == size);
    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        foodId: foodId,
        name: name,
        price: price,
        quantity: quantity,
        categoryId: categoryId,
        size: size,
        addons: addons ?? [],
      ));
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = newQuantity;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}