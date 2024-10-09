import 'package:flutter/material.dart';

Widget buildTextFormField({
  required String labelText,
  bool obscureText = false,
  required TextEditingController controller,
  TextInputType? keyboardType,
  Function(String)? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      style: TextStyle(color: Colors.grey[800]),
      obscureText: obscureText,
      keyboardType: keyboardType,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
        labelText: labelText,
      ),
    ),
  );
}
