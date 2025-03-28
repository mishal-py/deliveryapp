import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget{
  final Function()? onTap;
  final String text;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: Theme.of(context).colorScheme.secondary),
        child: Center(
          child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 20,)
            ,)
        ),
      ),
    );
  }
}