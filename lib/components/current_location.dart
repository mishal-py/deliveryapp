import 'package:flutter/material.dart';

class CurrentLocation extends StatelessWidget {
  const CurrentLocation({super.key});

  void openLocationSearchBox(BuildContext context) {
    showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        title: Text("Enter Your Location"),
        content: TextField(
          decoration: const InputDecoration(hintText: "Search Address"),
        ),
        actions: [
          MaterialButton(onPressed: ()=> Navigator.pop(context),
          child: const Text("Cancel"),
          ),

          MaterialButton(onPressed: ()=> Navigator.pop(context),
          child: const Text("save"),
          ),

        ],
      )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Delivery Now",
          style: TextStyle(color:  Theme.of(context).colorScheme.primary,),),
          GestureDetector(
            onTap: () => openLocationSearchBox(context),
            child: Row(
              children: [
                Text("Pokhara-25, hemja",
                style: TextStyle(
                  color:  Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
                ),
            
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ],
      ),
    );
  }
}