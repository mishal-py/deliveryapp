import 'package:flutter/material.dart';
import 'package:newapp/components/custom_textfield.dart';
import 'package:newapp/components/custom_button.dart';

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

  String? errorMessage;
  String? emailErrorMessage;
  bool isButtonEnabled = false;

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

  @override
  void initState() {
    super.initState();
    emailController.addListener(validateInputs);
    passwordController.addListener(validateInputs);
    confirmpasswordController.addListener(validateInputs);
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmpasswordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              onTap: isButtonEnabled ? () {} : null,
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
    );
  }
}