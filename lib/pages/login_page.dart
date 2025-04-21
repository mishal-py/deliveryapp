import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newapp/components/custom_textfield.dart';
import 'package:newapp/components/custom_button.dart';
import 'admin_panel.dart';
import 'package:newapp/pages/Home/homscreen.dart';
import 'package:newapp/pages/Home/kitchenhomescreen.dart';
import 'package:newapp/pages/Home/waiterhomescreen.dart';
import 'package:newapp/pages/Home/cashier_billing_screen.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Navigate based on user role and approval status
  Future<void> _navigateBasedOnRole(User user) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found')),
          );
        }
        return;
      }
      bool approved = userDoc['approved'] ?? false;
      String role = userDoc['role'] ?? 'client';
      print('Navigating with role: $role, approved: $approved for UID: ${user.uid}, Email: ${user.email}');

      if (!approved) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account awaiting admin approval')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      if (!mounted) return;

      switch (role) {
        case 'admin':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPanel()),
          );
          break;
        case 'kitchen':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const KitchenOrderScreen()),
          );
          break;
        case 'waiter':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WaiterHomeScreen()),
          );
          break;
        case 'cashier':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CashierBillingScreen()),
          );
          break;
        case 'client':
        default:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          break;
      }
    } catch (e) {
      print('Error checking role: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking role: $e')),
        );
      }
    }
  }

  Future<void> login() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists || userDoc['role'] == null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': userCredential.user!.email,
            'role': 'client',
            'approved': false,
            'createdAt': FieldValue.serverTimestamp(),
            'name': userCredential.user!.displayName ?? '',
            'photoUrl': userCredential.user!.photoURL ?? '',
          }, SetOptions(merge: true));
          print('UID: ${userCredential.user!.uid}, Assigned role: client for ${userCredential.user!.email}');
        } else {
          print('UID: ${userCredential.user!.uid}, Existing role: ${userDoc['role']} for ${userCredential.user!.email}');
        }
        await _navigateBasedOnRole(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists || userDoc['role'] == null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': userCredential.user!.email,
            'role': 'client',
            'approved': false,
            'createdAt': FieldValue.serverTimestamp(),
            'name': userCredential.user!.displayName,
            'photoUrl': userCredential.user!.photoURL,
          }, SetOptions(merge: true));
          print('UID: ${userCredential.user!.uid}, Assigned role: client for ${userCredential.user!.email}');
        } else {
          print('UID: ${userCredential.user!.uid}, Existing role: ${userDoc['role']} for ${userCredential.user!.email}');
        }
        await _navigateBasedOnRole(userCredential.user!);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign in failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/images/home/new.jpeg',
                height: 250,
              ),
              const SizedBox(height: 25),
              Text(
                "Food Delivery App",
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 25),
              CustomTextfield(
                controller: emailController,
                hintText: "E-mail",
                obscureText: false,
              ),
              const SizedBox(height: 25),
              CustomTextfield(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              const SizedBox(height: 25),
              CustomButton(
                text: "Sign In",
                onTap: _isLoading ? null : login,
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/images/home/google_logo.png',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text('Continue with Google'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register now",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}