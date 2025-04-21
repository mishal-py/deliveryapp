import 'package:flutter/material.dart';
import 'menu_repository.dart';
import '../../models/foods.dart';
import 'edit_food_item_screen.dart';

class MenuViewScreen extends StatelessWidget {
  final MenuRepository _repository = MenuRepository();

  MenuViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: StreamBuilder<List<MenuCategory>>(
        stream: _repository.getCategories(),
        builder: (context, categorySnapshot) {
          if (!categorySnapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: categorySnapshot.data!.map((category) {
              return StreamBuilder<List<FoodItem>>(
                stream: _repository.getFoodItems(category.id),
                builder: (context, foodSnapshot) {
                  if (!foodSnapshot.hasData) return const CircularProgressIndicator();
                  return ExpansionTile(
                    title: Text(category.name),
                    children: foodSnapshot.data!.map((food) {
                      return ListTile(
                        leading: food.photoUrl != null
                            ? Image.network(food.photoUrl!, width: 50, height: 50)
                            : const Icon(Icons.fastfood),
                        title: Text(food.name),
                        subtitle: Text('\Rs. ${food.price}\n${food.description}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditFoodItemScreen(foodItem: food),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}