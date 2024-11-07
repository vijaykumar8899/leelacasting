import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/Screens/CalculateScreen.dart';
import 'package:leelacasting/Screens/RecordScreen.dart';
import 'package:leelacasting/Screens/TabScreens.dart';

class TransactionDialog extends StatelessWidget {
  final String collectionPath;
  final String docId;

  const TransactionDialog({
    Key? key,
    required this.collectionPath,
    required this.docId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      title: Center(
        child: Text(
          'Leela Casting',
          style: GoogleFonts.italiana(
            textStyle: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      content: Container(
        margin: EdgeInsets.only(top: 20),
        height: 370,
        width: 500,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), // Curved border
            border: Border.all(
              color: Colors.white, // Border color
              width: 0, // Slight border width for visibility
            ),
            image: DecorationImage(
              image: NetworkImage(
                  'https://cdn.vectorstock.com/i/500p/81/36/luxury-black-gold-background-elegant-business-vector-52808136.jpg'), // Background image
              fit: BoxFit.cover, // Ensure the image covers the entire container
            ),
            gradient: LinearGradient(
              colors: [
                Colors.black54, // Add some transparency to enhance readability
                Colors.black54,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FetchDataOfPaticularRecord(
                  collectionPath: collectionPath,
                  docId: docId,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TabsScreen()),
            );
          },
          child: Text(
            'Print',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
