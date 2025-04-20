import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../models/foods.dart';

class MenuRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Add Category
  Future<void> addCategory(String name) async {
    try {
      String id = const Uuid().v4();
      await _firestore.collection('categories').doc(id).set(
            MenuCategory(id: id, name: name).toMap(),
          );
      print('Category added: $name (ID: $id)');
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

    // Fetch Categories
  Stream<List<MenuCategory>> getCategories() {
    try {
      return _firestore.collection('categories').snapshots().map(
            (snapshot) {
              print('Fetched ${snapshot.docs.length} categories');
              return snapshot.docs.map((doc) {
                print('Document data: ${doc.data()}');
                return MenuCategory.fromMap(doc.data());
              }).toList();
            },
          ).handleError((e) {
        print('Error fetching categories: $e');
        return [];
      });
    } catch (e) {
      print('Error setting up categories stream: $e');
      return Stream.value([]);
    }
  }


  Future<String?> uploadImage(File image) async {
    try {
      String fileName = const Uuid().v4();
      Reference ref = _storage.ref().child('menu_images/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> addFoodItem({
    required String categoryId,
    required String name,
    required double price,
    required String description,
    File? image,
    required List<Addon> addons,
  }) async {
    String? photoUrl;
    if (image != null) {
      photoUrl = await uploadImage(image);
    }

    String id = const Uuid().v4();
    await _firestore.collection('food_items').doc(id).set(
          FoodItem(
            id: id,
            categoryId: categoryId,
            name: name,
            price: price,
            photoUrl: photoUrl,
            description: description,
            addons: addons,
          ).toMap(),
        );
  }


  Stream<List<FoodItem>> getFoodItems(String categoryId) {
    return _firestore
        .collection('food_items')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FoodItem.fromMap(doc.data()))
              .toList(),
        );
  }

  // Update Data
  Future<void> updateFoodItem(FoodItem foodItem, File? newImage) async {
    String? photoUrl = foodItem.photoUrl;
    if (newImage != null) {
      photoUrl = await uploadImage(newImage);
    }

    await _firestore.collection('food_items').doc(foodItem.id).update(
          FoodItem(
            id: foodItem.id,
            categoryId: foodItem.categoryId,
            name: foodItem.name,
            price: foodItem.price,
            photoUrl: photoUrl,
            description: foodItem.description,
            addons: foodItem.addons,
          ).toMap(),
        );
  }
}