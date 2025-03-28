import 'package:flutter/material.dart';
import 'package:newapp/pages/login_page.dart';
import 'package:newapp/pages/register_page.dart';

class LoginOrRegistration extends StatefulWidget{
  const LoginOrRegistration({super.key});

  @override
  State<LoginOrRegistration> createState() => _LoginorRegistrationState();
}

class _LoginorRegistrationState extends State<LoginOrRegistration>{
  // initially lets show login page
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(onTap: togglePages,);
    }
    else{
      return RegisterPage(onTap: togglePages,);
    }
  }
}

