import 'package:flutter/material.dart';
import 'package:newapp/components/custom_textfield.dart';
import 'package:newapp/components/custom_button.dart';
import 'package:newapp/pages/home_page.dart';

class LoginPage extends StatefulWidget{
  final void Function()? onTap;

  const LoginPage({super.key,required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // TextEditingController
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  void login() {
    Navigator.push(context, 
    MaterialPageRoute(builder: (context)=> const HomePage(),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Image.asset(
                'lib/images/home/new.jpeg', 
                height: 250,
              ),

            const SizedBox(height: 25,),

            Text("Food Delivery App",
            style: TextStyle(
              fontSize: 22,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            ),

            const SizedBox(height: 25,),

            CustomTextfield(
            controller: emailController, 
            hintText: "E-mail", 
            obscureText: false),

            const SizedBox(height: 25,),

            CustomTextfield(
            controller: passwordController, 
            hintText: "Password", 
            obscureText: true),

            const SizedBox(height: 25,),


            CustomButton(text: "Sign In", onTap: login),

            const SizedBox(height: 25,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Not a member?",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary)
                ),
                const SizedBox(width: 5,),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Register now",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),



          ],
        ),
      ),
    );

  }
}