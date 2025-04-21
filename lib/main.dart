import 'package:flutter/material.dart';
import 'package:newapp/pages/Home/cashier_billing_screen.dart';
import 'package:newapp/pages/Home/clienthomescreen.dart';
import 'package:newapp/pages/Home/kitchenhomescreen.dart';
import 'package:newapp/pages/Home/waiterhomescreen.dart';
import 'package:newapp/pages/admin_panel.dart';
import 'package:newapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:newapp/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:newapp/firebase_options.dart';
import 'package:newapp/models/user_model.dart';
import 'package:newapp/pages/login_page.dart';
import 'package:newapp/pages/Home/client_checout_screen.dart';
import 'package:newapp/pages/Home/waiter_approve_order_screen.dart';
import 'package:newapp/pages/Home/waiter_order_screen.dart';
import 'package:newapp/pages/Home/client_cart_screen.dart';
import 'package:newapp/services/auth_service.dart';
import 'package:newapp/models/cart_model.dart';
import 'package:newapp/pages/Home/waiterpickup_screen.dart';
import 'package:newapp/pages/Home/waiter_details_screen.dart';
import 'package:newapp/pages/Home/homscreen.dart';
import 'package:newapp/pages/Home/notification_screen.dart';
import 'package:newapp/pages/Home/offer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        //ChangeNotifierProvider(create: (context) => Restaurant()),
        ChangeNotifierProvider(create: (context) => CartModel()),
        StreamProvider<AppUser?>(
          create: (_) => userStream(),
          initialData: null,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Widget to determine the home screen based on user role
  

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AppUser?>(
      builder: (context, themeProvider, user, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          initialRoute: '/',
          routes: {
            '/': (context) => const DeliverySplashScreen(),
            '/login': (context) => const LoginPage(onTap: null),
            '/admin_home': (context) => const AdminPanel(),
            '/client_home': (context) => const ClientHomeScreen(),
            '/client_cart': (context) => const ClientCartScreen(),
            '/client_checkout': (context) => const ClientCheckoutScreen(),
            '/waiter_home': (context) => const WaiterHomeScreen(),
            '/waiter_order': (context) => const WaiterOrderScreen(),
            '/waiter_approve_order': (context) => const WaiterApproveOrderScreen(),
            '/kitchen_order': (context) => const KitchenOrderScreen(),
            '/cashier_billing': (context) => const CashierBillingScreen(),
            '/waiter_order_details': (context) => const WaiterOrderDetailsScreen(),
            '/waiter_pickup': (context) => const WaiterPickupScreen(),
            '/Offer':(context) => const OfferScreen(),
            '/home':(context) => const HomeScreen(),
            '/Notification': (context) => const ClientNotificationScreen(),
          },
          // Override home to handle user role redirection after splash screen
        );
      },
    );
  }
}