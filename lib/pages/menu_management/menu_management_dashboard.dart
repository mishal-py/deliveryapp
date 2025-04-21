import 'package:flutter/material.dart';
import 'package:newapp/pages/menu_management/food_item_ManagementScreen';
import 'category_management_screen.dart';
import 'menu_view_screen.dart';
import '../../components/custom_button.dart';

class MenuManagementDashboard extends StatelessWidget {
  const MenuManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomButton(
              text: "Manage Categories",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
                );
              },
            ),
            const SizedBox(height: 16,),
            CustomButton(
              text: "Add Food items",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoodItemManagementScreen()),
                );
              },
            ),
             const SizedBox(height: 16,),
            CustomButton(
              text: "View Menu",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  MenuViewScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}