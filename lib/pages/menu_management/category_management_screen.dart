import 'package:flutter/material.dart';
import 'package:newapp/models/foods.dart';
import '../../components/custom_textfield.dart';
import '../menu_management/menu_repository.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _repository = MenuRepository();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() async {
    if (_categoryController.text.isNotEmpty) {
      try {
        await _repository.addCategory(_categoryController.text);
        _categoryController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add category: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CustomTextfield(
            controller: _categoryController, 
            hintText: 'category Name(e.g:- Momo,Pizza)', 
            obscureText: false),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCategory,
              child: const Text('Add Category'),
            ),
            const SizedBox(height: 20),
            const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<List<MenuCategory>>(
                stream: _repository.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print('StreamBuilder error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print('No categories found');
                    return const Center(child: Text('No categories available'));
                  }
                  final categories = snapshot.data!;
                  print('Rendering ${categories.length} categories');
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        title: Text(category.name),
                        subtitle: Text('ID: ${category.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}