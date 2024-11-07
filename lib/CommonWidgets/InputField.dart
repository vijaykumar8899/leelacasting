import 'package:flutter/material.dart';

Widget buildTextFormField({
  required String labelText,
  bool obscureText = false,
  required TextEditingController controller,
  TextInputType? keyboardType,
  Function(String)? onChanged,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 50),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        style: TextStyle(color: const Color.fromARGB(255, 172, 169, 169)),
        obscureText: obscureText,
        keyboardType: keyboardType,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 0, 0, 0),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: const Color.fromARGB(147, 255, 172, 64), width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: const Color.fromARGB(255, 88, 88, 88), width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: labelText,
          labelStyle: TextStyle(
            color: const Color.fromARGB(
                255, 146, 146, 146), // Set your desired label text color here
          ),
        ),
      ),
    ),
  );
}
