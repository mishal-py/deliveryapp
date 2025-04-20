import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newapp/components/custom_textfield.dart';
import 'package:uuid/uuid.dart';
import 'menu_repository.dart';
import '../../models/foods.dart';

class EditFoodItemScreen extends StatefulWidget {
  final FoodItem foodItem;

  const EditFoodItemScreen({super.key, required this.foodItem});

  @override
  State<EditFoodItemScreen> createState() => _EditFoodItemScreenState();
}

class _EditFoodItemScreenState extends State<EditFoodItemScreen> {
  final _repository = MenuRepository();
  final _foodNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addonNameController = TextEditingController();
  final _addonPriceController = TextEditingController();
  File? _selectedImage;
  String? _selectedCategoryId;
  List<Addon> _addons = [];

  @override
  void initState() {
    super.initState();
    _foodNameController.text = widget.foodItem.name;
    _priceController.text = widget.foodItem.price.toString();
    _descriptionController.text = widget.foodItem.description;
    _selectedCategoryId = widget.foodItem.categoryId;
    _addons = widget.foodItem.addons;
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _addonNameController.dispose();
    _addonPriceController.dispose();
    super.dispose();
  }

  void _updateFoodItem() async {
    if (_selectedCategoryId == null ||
        _foodNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    await _repository.updateFoodItem(
      FoodItem(
        id: widget.foodItem.id,
        categoryId: _selectedCategoryId!,
        name: _foodNameController.text,
        price: double.parse(_priceController.text),
        photoUrl: widget.foodItem.photoUrl,
        description: _descriptionController.text,
        addons: _addons,
      ),
      _selectedImage,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food item updated')),
    );
  }

  void _addAddon() {
    if (_addonNameController.text.isNotEmpty && _addonPriceController.text.isNotEmpty) {
      setState(() {
        _addons.add(Addon(
          id: const Uuid().v4(),
          name: _addonNameController.text,
          price: double.parse(_addonPriceController.text),
        ));
        _addonNameController.clear();
        _addonPriceController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Food Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Food Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder<List<MenuCategory>>(
              stream: _repository.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                var categories = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Category'),
                  value: _selectedCategoryId,
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategoryId = value),
                );
              },
            ),
            CustomTextfield(
              controller: _foodNameController,
              hintText: 'Food Name',
              obscureText: false,
            ),
             const SizedBox(height: 10,),
            CustomTextfield(
              controller: _priceController,
              hintText: 'Price',
              keyboardType: TextInputType.number,
              obscureText: false,
            ),
             const SizedBox(height: 10,),
            CustomTextfield(
              controller: _descriptionController,
              hintText: 'Description',
              obscureText: false,
            ),
            
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => _selectedImage = File(pickedFile.path));
                }
              },
              child: const Text('Pick New Image'),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 10),
              Image.file(_selectedImage!, height: 100, width: 100),
            ] else if (widget.foodItem.photoUrl != null) ...[
              const SizedBox(height: 10),
              Image.network(widget.foodItem.photoUrl!, height: 100, width: 100),
            ],
            const SizedBox(height: 20),
            const Text('Add Addons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
           CustomTextfield(
              controller: _addonNameController,
              hintText: 'Addon Name',
              obscureText: false,
            ),
             const SizedBox(height: 10,), 
            CustomTextfield(
              controller: _addonPriceController,
              hintText: 'Addon Price',
              keyboardType: TextInputType.number,
              obscureText: false,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addAddon,
              child: const Text('Add Addon'),
            ),
            const SizedBox(height: 10),
            if (_addons.isNotEmpty) ...[
              const Text('Added Addons:'),
              ..._addons.map((addon) => ListTile(
                    title: Text('${addon.name} - \Rs.${addon.price}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _addons.remove(addon)),
                    ),
                  )),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateFoodItem,
              child: const Text('Update Food Item'),
            ),
          ],
        ),
      ),
    );
  }
}