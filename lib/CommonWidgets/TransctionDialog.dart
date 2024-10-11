// transaction_dialog.dart
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: const Color.fromARGB(255, 178, 212, 240),
      title: Center(
        child: Text(
          'Leela Casting',
          style: GoogleFonts.italiana(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      content: Container(
        height: 370,
        width: 500,
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(width: 2.0, color: Colors.white),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TabsScreen()),
            );
          },
          child: const Text('Print'),
        ),
      ],
    );
  }
}
