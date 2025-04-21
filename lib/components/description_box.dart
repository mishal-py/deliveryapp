import 'package:flutter/material.dart';

class DescriptionBox extends StatelessWidget {
  const DescriptionBox({super.key});

  @override
  Widget build(BuildContext context) {

    var PrimaryTextstyle = TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    var SecondaryTextstyle = TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.only(left: 25,right: 25,bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text("Nrs.150",style: PrimaryTextstyle,),
                Text("Delivery Fee",style: SecondaryTextstyle,),
              ],
            ),

            Column(
              children: [
                Text("15 - 20 min",style: PrimaryTextstyle,),
                Text("Delivery Time", style: SecondaryTextstyle,),
              ],
            ),
          ],
        ),
      );
  }

}