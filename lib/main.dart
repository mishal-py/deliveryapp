import 'package:flutter/material.dart';
import 'package:newapp/models/cart_model.dart';
import 'package:newapp/models/resturant.dart';
import 'package:newapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),

      ChangeNotifierProvider(create: (context) => Restaurant()),

      ChangeNotifierProvider(create: (context) => CartModel()),
    ],
    child: const Myapp(),
    )
    
  );
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DeliverySplashScreen(),
      theme: Provider.of<ThemeProvider>(context).themeData,

    );
  }
}