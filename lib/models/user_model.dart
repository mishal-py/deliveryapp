// user model
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String role;
  final bool approved;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.approved,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return AppUser(
      id: doc.id,
      email: data?['email'] ?? '',
      role: data?['role'] ?? '',
      approved: data?['approved'] ?? false,
    );
  }

  String? get uid => null;
}
