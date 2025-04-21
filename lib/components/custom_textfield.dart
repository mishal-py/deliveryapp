import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  _CustomTextfieldState createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: Theme.of(context).colorScheme.primary)
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}