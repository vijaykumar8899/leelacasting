import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ColumnBox extends StatelessWidget {
  String text; // Use camelCase for variable names
  int num;
  double weight;
  ColumnBox({required this.text, required this.num, required this.weight});

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextBoxBold(text: text),
        const Text("__________"),
        TextBoxNormal(text: weight.toStringAsFixed(num)),
      ],
    );
  }
}

class TextBoxBold extends StatelessWidget {
  String text; // Use camelCase for variable names

  TextBoxBold({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text, // Use the 'text' parameter here
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
        color: Colors.black,
      ),
    );
  }
}

class TextBoxNormal extends StatelessWidget {
  String text; // Use camelCase for variable names

  TextBoxNormal({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 18.0,
        color: Colors.black,
      ),
    );
  }
}

class SpaceBox extends StatelessWidget {
  double size;

  SpaceBox({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
    );
  }
}

class SpaceBoxHeight extends StatelessWidget {
  double size;

  SpaceBoxHeight({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
    );
  }
}

class LoadingClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(
      size: 75,
      color: Color.fromARGB(255, 5, 97, 171),
    );
  }
}