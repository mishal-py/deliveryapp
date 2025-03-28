import 'package:flutter/material.dart';
import 'package:newapp/models/foods.dart';

class CustomTabBar extends StatelessWidget {

  final TabController tabController;

  const CustomTabBar({
    super.key,
    required this.tabController,
    });

    List<Tab> _buildCategoryTabs() {
      return FoodCategory.values.map((category) {
        return Tab(
          text: category.toString().split('.').last,
        );
      }).toList();
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TabBar(
      controller: tabController,
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      tabs: _buildCategoryTabs(),
      ),
    );
  }
}