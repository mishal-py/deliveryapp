import 'package:flutter/material.dart';
import 'package:newapp/authentication/login_or_registration.dart';
import 'package:newapp/components/custom_button.dart';

class DeliverySplashScreen extends StatelessWidget {
  const DeliverySplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Delivery-themed image
              Image.asset(
                'lib/images/home/splash.jpg', 
                height: 250,
              ),
              const SizedBox(height: 20),
              
              // Main Title modified for delivery
              const Text(
                'Fast, Reliable Delivery at Your Doorstep',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              
              Text(
                'Experience quick deliveries with real-time tracking, easy ordering, '
                'and secure payments. Get your favorites delivered fresh and fast!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 50),
              
              CustomButton(
                text: "Get Started",
                onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> const LoginOrRegistration(),
                        )
                        );
                      }
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}