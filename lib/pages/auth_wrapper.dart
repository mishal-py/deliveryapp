import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'admin_panel.dart';
import '../models/user_model.dart';
import 'waiting_screen.dart';
import '../authentication/login_or_registration.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Stream<AppUser?> getUserStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!authSnapshot.hasData) {
          return LoginOrRegistration(); // You don't need a navigator push here
        }

        return StreamProvider<AppUser?>.value(
          value: getUserStream(authSnapshot.data!.uid),
          initialData: null,
          catchError: (_, __) => null,
          child: const AuthenticatedRouter(),
        );
      },
    );
  }
}

class AuthenticatedRouter extends StatelessWidget {
  const AuthenticatedRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!user.approved) return const WaitingScreen();
    if (user.role == 'admin') return const AdminPanel();

    return const LoginOrRegistration();
  }
}
