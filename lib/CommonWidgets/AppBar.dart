import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({super.key});

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "My Pranaya Cinematic",
        style: GoogleFonts.rowdies(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(FontAwesomeIcons.user),
            onPressed: () async {},
          ),
        ),
      ],
      elevation: 0,
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 243, 18, 2),
    );
  }
}
