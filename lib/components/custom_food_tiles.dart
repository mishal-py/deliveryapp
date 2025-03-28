import 'package:flutter/material.dart';
import 'package:newapp/models/foods.dart';

class CustomFoodTiles extends StatelessWidget {
  final Foods foods;
  final void Function()? onTap;

  const CustomFoodTiles({
    super.key,
    required this.foods,
    required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [

                // text food details
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(foods.name),
                    const SizedBox(height: 10,),
                    Text("Nrs."+foods.price.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    ),
                    const SizedBox(height: 10,),
                    Text(foods.description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    ),
                  ],
                ),
                ),

                const SizedBox(width: 15,),

                ClipRRect(
                  borderRadius: BorderRadius.circular(9),  
                  child: Image.asset(foods.imagepath,height: 120,width: 120,)),
              ],
            ),
          ),
        ),
        Divider(
          color:  Theme.of(context).colorScheme.tertiary,
          endIndent: 25,
          indent: 25,

        ),
      ],
    );
  }
}