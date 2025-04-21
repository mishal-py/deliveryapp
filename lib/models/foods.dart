class MenuCategory {
  final String id;
  final String name;

  MenuCategory({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory MenuCategory.fromMap(Map<String, dynamic> map) {
    return MenuCategory(id: map['id']??'', 
    name: map['name']?? 'Unknown',
    );
  }
}

class FoodItem {
  final String id;
  final String categoryId;
  final String name;
  final double price;
  final String? photoUrl;
  final String description;
  final List<Addon> addons;
  final bool isSpecialOffer;

  FoodItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.photoUrl,
    required this.description,
    required this.addons,
    this.isSpecialOffer = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'photoUrl': photoUrl,
      'description': description,
      'addons': addons.map((addon) => addon.toMap()).toList(),
      'isSpecialOffer': isSpecialOffer,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      categoryId: map['categoryId'],
      name: map['name'],
      price: map['price'].toDouble(),
      photoUrl: map['photoUrl'],
      description: map['description'],
      addons: (map['addons'] as List).map((addon) => Addon.fromMap(addon)).toList(),
      isSpecialOffer: map['isSpecialOffer'] ?? false,
    );
  }
}

class Addon {
  final String id;
  final String name;
  final double price;

  Addon({required this.id, required this.name, required this.price});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price};
  }

  factory Addon.fromMap(Map<String, dynamic> map) {
    return Addon(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
    );
  }
}