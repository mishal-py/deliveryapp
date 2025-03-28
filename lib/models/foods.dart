
class Foods {
  final String name;
  final String description;
  final String imagepath;
  final double price;
  final FoodCategory category;
  List<Addon> availableAddons;

  Foods ({
    required this.name,
    required this.description,
    required this.imagepath,
    required this.price,
    required this.availableAddons,
    required this.category,
  });
}
  enum FoodCategory{
    burgers,
    pizzas,
    momos,
    desserts,
    drinks,
    biryani,
    noodles,
  }

  class Addon{
    String name;
    double price;

    Addon({
      required this.name,
      required this.price,
    });
  }

