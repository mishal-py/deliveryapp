import 'package:flutter/material.dart';
import 'package:newapp/components/custom_drawer_tile.dart';
import 'package:newapp/pages/setting_page.dart';
import 'package:newapp/authentication/login_or_registration.dart';
import 'package:newapp/pages/home_page.dart';
import 'package:newapp/pages/profile_page.dart';
import 'package:newapp/pages/notification_page.dart';
import 'package:newapp/pages/offer_page.dart';

class CustomDrawer extends StatelessWidget{
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Image.asset(
                'lib/images/home/new.jpeg', 
                height: 40,
              ),
          ),

          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
            ),
           
          CustomDrawerTile(
          text: "H O M E", 
          icon: Icons.home, 
          onTap: (){
            Navigator.pop(context);
            Navigator.push(context,
             MaterialPageRoute(builder: (context)=> const HomePage(),
             )
             );
          }
          ),

          CustomDrawerTile(
          text: "S E T T I N G S", 
          icon: Icons.settings, 
          onTap: (){
            Navigator.pop(context);
            Navigator.push(context,
             MaterialPageRoute(builder: (context)=> const SettingPage(),
             )
             );
          }),

          CustomDrawerTile(
          text: "P R O F I L E", 
          icon: Icons.person_2_rounded, 
          onTap: (){
            Navigator.pop(context);
            Navigator.push(context,
             MaterialPageRoute(builder: (context)=> const ProfileScreen(),
             )
             );
          }),

          CustomDrawerTile(
          text: "N O T I F I C A T I O N", 
          icon: Icons.notifications_active, 
          onTap: (){
            Navigator.pop(context);
            Navigator.push(context,
             MaterialPageRoute(builder: (context)=> const NotificationPage(),
             )
             );
            }),

            CustomDrawerTile(
              text: "O F F E R S", 
              icon: Icons.monetization_on_sharp, 
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context,
                MaterialPageRoute(builder: (context)=> const OfferPage(),
                )
                );
            }),

          const Spacer(),


          CustomDrawerTile(
          text: "L O G O U T", 
          icon: Icons.logout, 
          onTap: (){
            Navigator.pop(context);
            Navigator.push(context,
             MaterialPageRoute(builder: (context)=> const LoginOrRegistration(),
             )
             );
          }),
            
        ],
      ),
    );
  }
}
