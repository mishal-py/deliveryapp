import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

Stream<AppUser?> userStream() {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return AppUser.fromFirestore(doc);
  });
}
