import 'package:flutter/material.dart';
import 'package:newapp/models/foods.dart';

class Restaurant extends ChangeNotifier{
  final List<Foods> _menu = [
    // Burgers 🍔
    Foods(
      name: "Classic Cheese Burger",
      description: "Beef patty with cheddar, lettuce, tomato, onion, and pickle.",
      imagepath: "lib/images/burgers/burger1.png",
      price: 850,
      availableAddons: [
        Addon(name: "Extra cheese", price: 50),
        Addon(name: "Bacon", price: 100),
      ],
      category: FoodCategory.burgers,
    ),
    Foods(
      name: "Double Patty Burger",
      description: "Two beef patties stacked with cheddar cheese and caramelized onions.",
      imagepath: "lib/images/burgers/burger2.png",
      price: 950,
      availableAddons: [
        Addon(name: "Extra cheese", price: 50),
      ],
      category: FoodCategory.burgers,
    ),
    Foods(
      name: "Spicy Chicken Burger",
      description: "Crispy fried chicken breast with spicy sauce and lettuce.",
      imagepath: "lib/images/burgers/burger3.png",
      price: 800,
      availableAddons: [
        Addon(name: "Jalapenos", price: 40),
      ],
      category: FoodCategory.burgers,
    ),
    Foods(
      name: "BBQ Beef Burger",
      description: "Grilled beef patty with smoky BBQ sauce and cheddar cheese.",
      imagepath: "lib/images/burgers/burger4.png",
      price: 900,
      availableAddons: [
        Addon(name: "Onion Rings", price: 70),
      ],
      category: FoodCategory.burgers,
    ),
    Foods(
      name: "Veggie Delight Burger",
      description: "A vegetarian burger with fresh veggies, cheese, and sauce.",
      imagepath: "lib/images/burgers/burger5.png",
      price: 750,
      availableAddons: [
        Addon(name: "Paneer Slice", price: 80),
      ],
      category: FoodCategory.burgers,
    ),

    // Biryani 🍛
    Foods(
      name: "Hyderabadi Biryani",
      description: "Aromatic rice with marinated chicken and spices.",
      imagepath: "lib/images/biryani/biryani1.jpeg",
      price: 600,
      availableAddons: [
        Addon(name: "Extra Chicken", price: 150),
      ],
      category: FoodCategory.biryani,
    ),
    Foods(
      name: "Mutton Biryani",
      description: "Tender mutton pieces with fragrant rice and spices.",
      imagepath: "lib/images/biryani/biryani2.jpeg",
      price: 750,
      availableAddons: [
        Addon(name: "Extra Mutton", price: 200),
      ],
      category: FoodCategory.biryani,
    ),
    Foods(
      name: "Vegetable Biryani",
      description: "Basmati rice with fresh vegetables and spices.",
      imagepath: "lib/images/biryani/biryani3.jpeg",
      price: 500,
      availableAddons: [
        Addon(name: "Extra Paneer", price: 100),
      ],
      category: FoodCategory.biryani,
    ),
    Foods(
      name: "Egg Biryani",
      description: "Flavored rice with boiled eggs and spices.",
      imagepath: "lib/images/biryani/biryani4.jpeg",
      price: 550,
      availableAddons: [
        Addon(name: "Extra Egg", price: 50),
      ],
      category: FoodCategory.biryani,
    ),
    Foods(
      name: "Prawn Biryani",
      description: "Biryani made with fresh prawns and saffron rice.",
      imagepath: "lib/images/biryani/biryani5.png",
      price: 800,
      availableAddons: [
        Addon(name: "Extra Prawns", price: 200),
      ],
      category: FoodCategory.biryani,
    ),

    // Desserts 🍫
    Foods(
      name: "Chocolate Brownie",
      description: "Rich and fudgy brownie with vanilla ice cream.",
      imagepath: "lib/images/desserts/deserts1.jpeg",
      price: 250,
      availableAddons: [
        Addon(name: "Extra Ice Cream", price: 50),
      ],
      category: FoodCategory.desserts,
    ),
    Foods(
      name: "Cheesecake",
      description: "Creamy cheesecake with strawberry topping.",
      imagepath: "lib/images/desserts/deserts2.jpg",
      price: 300,
      availableAddons: [
        Addon(name: "Extra Berries", price: 60),
      ],
      category: FoodCategory.desserts,
    ),
    Foods(
      name: "Chocolate Lava Cake",
      description: "Warm lava cake with melted chocolate inside.",
      imagepath: "lib/images/desserts/deserts3.jpg",
      price: 350,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Extra Berries", price: 60),
      ],
    ),
    Foods(
      name: "Gulab Jamun",
      description: "Soft milk dumplings soaked in sugar syrup.",
      imagepath: "lib/images/desserts/deserts4.jpg",
      price: 150,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Extra Berries", price: 60),
      ],
    ),
    Foods(
      name: "Fruit Custard",
      description: "Delicious custard mixed with fresh fruits.",
      imagepath: "lib/images/desserts/deserts5.jpg",
      price: 200,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Extra Berries", price: 60),
      ],
    ),

    // Drinks 🥤
    Foods(
      name: "Cold Coffee",
      description: "Chilled coffee blended with frothy milk and chocolate syrup.",
      imagepath: "lib/images/drinks/drinks1.jpg",
      price: 200,
      availableAddons: [
        Addon(name: "Extra Chocolate", price: 50),
        Addon(name: "Whipped Cream", price: 40),
      ],
      category: FoodCategory.drinks,
    ),
    Foods(
      name: "Fresh Lime Soda",
      description: "Refreshing soda infused with fresh lime and mint.",
      imagepath: "lib/images/drinks/drinks2.jpg",
      price: 150,
      availableAddons: [
        Addon(name: "Extra Mint", price: 30),
        Addon(name: "Honey", price: 40),
      ],
      category: FoodCategory.drinks,
    ),
    Foods(
      name: "Mango Smoothie",
      description: "Creamy mango smoothie with a touch of honey and yogurt.",
      imagepath: "lib/images/drinks/drinks3.jpg",
      price: 250,
      availableAddons: [
        Addon(name: "Extra Mango", price: 50),
        Addon(name: "Chia Seeds", price: 60),
      ],
      category: FoodCategory.drinks,
    ),
    Foods(
      name: "Strawberry Milkshake",
      description: "Blended strawberries with milk and ice cream.",
      imagepath: "lib/images/drinks/drinks4.jpg",
      price: 220,
      availableAddons: [
        Addon(name: "Extra Ice Cream", price: 70),
        Addon(name: "Choco Chips", price: 50),
      ],
      category: FoodCategory.drinks,
    ),
    Foods(
      name: "Iced Tea",
      description: "Chilled iced tea with a splash of lemon.",
      imagepath: "lib/images/drinks/drinks5.png",
      price: 180,
      availableAddons: [
        Addon(name: "Extra Lemon", price: 20),
        Addon(name: "Honey", price: 40),
      ],
      category: FoodCategory.drinks,
    ),

    // Momos 🥟
    Foods(
      name: "Steam Chicken Momo",
      description: "Soft and juicy chicken dumplings served with spicy chutney.",
      imagepath: "lib/images/momos/momo1.jpg",
      price: 200,
      availableAddons: [
        Addon(name: "Extra Chutney", price: 30),
        Addon(name: "Cheese Filling", price: 50),
      ],
      category: FoodCategory.momos,
    ),
    Foods(
      name: "Buff Fried Momo",
      description: "Crispy fried buff momos served with creamy mayo dip.",
      imagepath: "lib/images/momos/momo2.jpg",
      price: 250,
      availableAddons: [
        Addon(name: "Extra Mayo Dip", price: 30),
        Addon(name: "Chili Flakes", price: 20),
      ],
      category: FoodCategory.momos,
    ),
    Foods(
      name: "Veg Jhol Momo",
      description: "Steamed vegetable momos dipped in flavorful jhol (soup).",
      imagepath: "lib/images/momos/momo3.jpg",
      price: 180,
      availableAddons: [
        Addon(name: "Extra Jhol", price: 40),
        Addon(name: "Tofu Filling", price: 50),
      ],
      category: FoodCategory.momos,
    ),
    Foods(
      name: "Pork Kothey Momo",
      description: "Pan-fried pork momos with a crispy bottom and juicy filling.",
      imagepath: "lib/images/momos/momo4.jpg",
      price: 270,
      availableAddons: [
        Addon(name: "Extra Spicy Sauce", price: 30),
        Addon(name: "Sesame Seeds", price: 20),
      ],
      category: FoodCategory.momos,
    ),
    Foods(
      name: "Cheese Momo",
      description: "Cheese-filled momos with a soft, melt-in-your-mouth texture.",
      imagepath: "lib/images/momos/momo5.jpg",
      price: 230,
      availableAddons: [
        Addon(name: "Extra Cheese", price: 50),
        Addon(name: "Oregano Topping", price: 20),
      ],
      category: FoodCategory.momos,
    ),

    // Noodles 🍜
    Foods(
      name: "Veg Chowmein",
      description: "Stir-fried noodles with fresh vegetables and special seasoning.",
      imagepath: "lib/images/noodles/noodes1.jpg",
      price: 180,
      availableAddons: [
        Addon(name: "Extra Chili Sauce", price: 20),
        Addon(name: "Paneer Cubes", price: 50),
      ],
      category: FoodCategory.noodles,
    ),
    Foods(
      name: "Chicken Chowmein",
      description: "Classic chicken chowmein with tender chicken strips and flavorful sauce.",
      imagepath: "lib/images/noodles/noodes2.jpg",
      price: 220,
      availableAddons: [
        Addon(name: "Extra Chicken", price: 70),
        Addon(name: "Extra Egg", price: 30),
      ],
      category: FoodCategory.noodles,
    ),
    Foods(
      name: "Buff Thukpa",
      description: "Traditional Tibetan noodle soup with juicy buff meat and rich broth.",
      imagepath: "lib/images/noodles/noodes3.jpeg",
      price: 250,
      availableAddons: [
        Addon(name: "Extra Buff Meat", price: 80),
        Addon(name: "Boiled Egg", price: 40),
      ],
      category: FoodCategory.noodles,
    ),
    Foods(
      name: "Prawn Hakka Noodles",
      description: "Chinese-style Hakka noodles stir-fried with fresh prawns.",
      imagepath: "lib/images/noodles/noodes4.jpeg",
      price: 300,
      availableAddons: [
        Addon(name: "Extra Prawns", price: 100),
        Addon(name: "Garlic Butter Topping", price: 50),
      ],
      category: FoodCategory.noodles,
    ),
    Foods(
      name: "Spicy Schezwan Noodles",
      description: "Fiery Schezwan noodles with a perfect balance of spice and tanginess.",
      imagepath: "lib/images/noodles/noodes5.jpeg",
      price: 200,
      availableAddons: [
        Addon(name: "Extra Schezwan Sauce", price: 30),
        Addon(name: "Crispy Fried Onions", price: 20),
      ],
      category: FoodCategory.noodles,
    ),

    // Pizzas 🍕
    Foods(
      name: "Margherita Pizza",
      description: "Classic pizza with fresh tomatoes, mozzarella cheese, and basil.",
      imagepath: "lib/images/pizzas/pizza1.jpg",
      price: 500,
      availableAddons: [
        Addon(name: "Extra Cheese", price: 80),
        Addon(name: "Olives", price: 50),
      ],
      category: FoodCategory.pizzas,
    ),
    Foods(
      name: "Pepperoni Pizza",
      description: "Delicious pizza topped with spicy pepperoni and mozzarella cheese.",
      imagepath: "lib/images/pizzas/pizza2.jpg",
      price: 650,
      availableAddons: [
        Addon(name: "Extra Pepperoni", price: 100),
        Addon(name: "Stuffed Crust", price: 120),
      ],
      category: FoodCategory.pizzas,
    ),
    Foods(
      name: "BBQ Chicken Pizza",
      description: "Smoky BBQ chicken with onions and melted cheese on a crispy crust.",
      imagepath: "lib/images/pizzas/pizza3.jpeg",
      price: 700,
      availableAddons: [
        Addon(name: "Extra Chicken", price: 120),
        Addon(name: "Ranch Sauce", price: 40),
      ],
      category: FoodCategory.pizzas,
    ),
    Foods(
      name: "Veggie Supreme Pizza",
      description: "Loaded with fresh vegetables, olives, mushrooms, and bell peppers.",
      imagepath: "lib/images/pizzas/pizza4.jpeg",
      price: 600,
      availableAddons: [
        Addon(name: "Jalapenos", price: 50),
        Addon(name: "Extra Mushrooms", price: 70),
      ],
      category: FoodCategory.pizzas,
    ),
    Foods(
      name: "Four Cheese Pizza",
      description: "A blend of mozzarella, cheddar, parmesan, and blue cheese.",
      imagepath: "lib/images/pizzas/pizza5.jpeg",
      price: 750,
      availableAddons: [
        Addon(name: "Garlic Butter Crust", price: 60),
        Addon(name: "Basil Leaves", price: 30),
      ],
      category: FoodCategory.pizzas,
    ),
  ];

  List<Foods> get menu => _menu;
}
