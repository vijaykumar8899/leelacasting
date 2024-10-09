import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/Screens/HomeScreen.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:leelacasting/Utilites/Colors.dart';

class CalculateScreen extends StatefulWidget {

  String collectionPath;
  String docId;

  CalculateScreen({super.key, required this.collectionPath, required this.docId});

  @override
  State<CalculateScreen> createState() => _CalculateScreenState();
}

class _CalculateScreenState extends State<CalculateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Calculate Page",
          style: GoogleFonts.rowdies(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 16.0),
          //   child: IconButton(
          //     icon: const Icon(FontAwesomeIcons.barcode),
          //     onPressed: () async {},
          //   ),
          // ),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryClr,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              // child: FetchDataOfPaticularRecord(
              //   collectionPath: widget.collectionPath,
              //   docId: widget.docId,
              // ),
              child: Text('data'),
            ),
          ],
        ),
      ),
    );
  }
}

class FetchDataOfPaticularRecord extends StatelessWidget {
  final String collectionPath;
  final String docId;

  FetchDataOfPaticularRecord({super.key, required this.collectionPath, required this.docId});

  @override
  Widget build(BuildContext context) {
    // Create a stream to listen to the document data.
    var stream_ = FirebaseFirestore.instance
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(collectionPath) // Specify the collection
        .doc(docId)
        .snapshots();

    return Scaffold(
      body: Container(
        width: 340,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.secondaryClr,
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: stream_,
          builder: (context, snapshot) {
            // Check for error in snapshot
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Show loading indicator while waiting for data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // Check if the snapshot has data and the document exists
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No data available'));
            }

            // Extract document data
            var doc = snapshot.data!;
            Timestamp timeStamp = doc['timeStamp'] as Timestamp;
            DateTime dateTime = timeStamp.toDate();

            return Padding(
              padding: const EdgeInsets.all(8.0),
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
                      Row(
                        children: [
                          Text("Name: ${doc['name']}"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Timestamp: ${dateTime.toString()}"),
                      // You can display more fields here as required.
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
