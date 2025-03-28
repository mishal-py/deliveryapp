import 'package:newapp/models/foods.dart';
class CartItem {
  final Foods food;
  final List<Addon> selectedAddons;
  int quantity;

  CartItem({
    required this.food,
    required this.selectedAddons,
    this.quantity = 1,
  });

  double get totalPrice {
    return (food.price + 
           selectedAddons.fold(0, (sum, addon) => sum + addon.price)) * quantity;
  }

  // For comparing if items are identical
  bool isSameItem(CartItem other) {
    return food == other.food && 
           _compareAddons(selectedAddons, other.selectedAddons);
  }

  bool _compareAddons(List<Addon> a, List<Addon> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].name != b[i].name || a[i].price != b[i].price) return false;
    }
    return true;
  }
}