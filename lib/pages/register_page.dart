// register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newapp/components/custom_textfield.dart';
import 'package:newapp/components/custom_button.dart';
import 'package:newapp/pages/waiting_screen.dart';


class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // TextEditingController
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? errorMessage;
  String? emailErrorMessage;
  bool isButtonEnabled = false;
  bool _isLoading = false;

   bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(email);
  }

  void validateInputs() {
    setState(() {
      if (emailController.text.isEmpty) {
        emailErrorMessage = "Email is required";
      } else if (!isValidEmail(emailController.text)) {
        emailErrorMessage = "Enter a valid email";
      } else {
        emailErrorMessage = null;
      }

      if (passwordController.text.isEmpty || confirmpasswordController.text.isEmpty) {
        errorMessage = null;
        isButtonEnabled = false;
      } else if (passwordController.text == confirmpasswordController.text) {
        errorMessage = null;
        isButtonEnabled = emailErrorMessage == null;
      } else {
        errorMessage = "Passwords do not match";
        isButtonEnabled = false;
      }
    });
  }

    Future<void> _registerUser() async {
    setState(() => _isLoading = true);
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Create user document with pending approval
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': emailController.text.trim(),
        'role': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'approved': false,
        'requestedRole': 'client',
      }).then((_) {
        print("✅ Firestore user document created!");
      }).catchError((error) {
        print("❌ Error writing to Firestore: $error");
      });
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WaitingScreen()),
        );
      }

    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    
  }
  

  void _handleAuthError(FirebaseAuthException e) {
    String message = 'Registration failed';
    if (e.code == 'weak-password') message = 'Password is too weak';
    if (e.code == 'email-already-in-use') message = 'Email already exists';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
          children: [
            // Logo
            Image.asset(
                'lib/images/home/new.jpeg', 
                height: 100,
              ),
            const SizedBox(height: 25),
            Text(
              "Let's Create Account for you",
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
            if (emailErrorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  emailErrorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 25),
            CustomTextfield(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),
            const SizedBox(height: 25),
            CustomTextfield(
              controller: confirmpasswordController,
              hintText: "Confirm Password",
              obscureText: true,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 25),
            CustomButton(
              text: "Sign up",
               onTap: !_isLoading ? _registerUser : null,
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already Have an Account?",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Login now",
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
    @override
  void dispose() {
    passwordController.dispose();
    confirmpasswordController.dispose();
    emailController.dispose();
    super.dispose();
  }
}