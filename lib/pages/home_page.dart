import 'package:flutter/material.dart';
import 'package:newapp/components/custom_food_tiles.dart';
import 'package:newapp/pages/food_page.dart';
import 'package:provider/provider.dart';
import 'package:newapp/components/custom_drawer.dart';
import 'package:newapp/components/my_sliver_app_bar.dart';
import 'package:newapp/components/current_location.dart';
import 'package:newapp/components/description_box.dart';
import 'package:newapp/components/custom_tab_bar.dart';
import 'package:newapp/models/foods.dart';
import 'package:newapp/models/resturant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePagestate();
}

class _HomePagestate extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: FoodCategory.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Foods> _filteredMenuByCategory(FoodCategory category, List<Foods> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  List<Widget> getFoodInThisCategory(List<Foods> fullMenu) {
    return FoodCategory.values.map((category) {
      List<Foods> categoryMenu = _filteredMenuByCategory(category, fullMenu);
      return ListView.builder(
        itemCount: categoryMenu.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final foods = categoryMenu[index];

          return CustomFoodTiles(foods: foods, onTap: ()=>
          Navigator.push(
            context,MaterialPageRoute(builder: (context)=> FoodPage(foods: foods),)
          ),); 
          
        },
      );
    }).toList(); // Convert to List<Widget>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          MySliverAppBar(
            title: CustomTabBar(tabController: _tabController),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Divider(
                  indent: 25,
                  endIndent: 25,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const CurrentLocation(),
                const DescriptionBox(),
              ],
            ),
          ),
        ],
        body: Consumer<Restaurant>(builder: (context,restaurant,child) =>TabBarView(
              controller: _tabController,
              children: getFoodInThisCategory(restaurant.menu), // Pass filtered menu
            ),),
        ),
    );
  }
}
