// import 'package:flutter/material.dart';

// class InputField extends StatelessWidget {
//     String labelText;
//     IconData prefixIcon;
//     TextEditingController controller;
    

//   InputField({
//     required String labelText,
//     required IconData prefixIcon,
//     required TextEditingController controller
//   });

//   @override
//   Widget build(BuildContext context) {
//     bool obscureText = false;
//     TextInputType? keyboardType;

//     return TextFormField(
//       style: TextStyle(color: Colors.grey[800]),
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       controller: controller,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.grey[200],
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.orangeAccent, width: 2.0),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.grey[400]!, width: 2.0),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         labelText: labelText,
//         prefixIcon: Icon(prefixIcon, color: Colors.grey[800]),
//       ),
//     );
//   }
// }
