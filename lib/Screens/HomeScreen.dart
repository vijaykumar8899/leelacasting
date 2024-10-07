import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/Screens/TransactionSaveScreen.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:leelacasting/Utilites/Colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<QuerySnapshot<Map<String, dynamic>>>
      fetchAllDocumentSnapshots() async {
    return await FirebaseFirestore.instance
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection('allDataCollection')
        .orderBy('timeStamp', descending: true)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Input Data",
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
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: fetchAllDocumentSnapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No documents found'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final document = snapshot.data!.docs[index];
                final documentID = document.id;
                final documentData = document.data() as Map<String, dynamic>;
                print('documentData : $documentData');

                return Column(
                  children: [
                    Text(documentID),
                    
                    DisplayDataFromFirebase(
                      collectionPath: documentID,
                    )
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TransactionSaveScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class customDataDisplay extends StatelessWidget {
  const customDataDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}

class DisplayDataFromFirebase extends StatelessWidget {
  var collectionPath;

  DisplayDataFromFirebase({super.key, required this.collectionPath});

  void showDeleteConfirmationDialog(
      String documentId, context, String imageUrl) {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    final collection = firestore
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(collectionPath);

    Reference imageRef = storage.refFromURL(imageUrl);

    showDialog(
      context: context,
      builder: (BuildContext outerContext) {
        return AlertDialog(
          title: const Text('Do you want to delete record?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // DeleteOrmakeAdmin(documentId, userName, 'Admin', outerContext);
                print('docId : $documentId');
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // DeleteOrmakeAdmin(documentId, userName, 'Delete', outerContext);
                print('docId : $documentId');
                await collection.doc(documentId).delete();
                await imageRef.delete();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var stream_ = FirebaseFirestore.instance
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(collectionPath) // Replace with your date
        .orderBy('timeStamp', descending: true)
        .snapshots();
    // print('collectionPath : $collectionPath');

    return Scaffold(
      body: Container(
        width: 340,
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [Color.fromARGB(255, 178, 212, 240), Colors.white],
        //     stops: [0.3, 1.0],
        //   ),
        // ),
        // color: Colors.green,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.secondaryClr,
        ),
        child: StreamBuilder(
          stream: stream_,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No data available'));
            }

            return ListView.builder(
              // physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var doc = snapshot.data!.docs[index];
                Timestamp timeStamp = doc['timeStamp'] as Timestamp;
                // Convert Firestore Timestamp to DateTime
                DateTime dateTime = timeStamp.toDate();

                // Format DateTime object to a string in your desired format
                // String formattedDateTime =
                //     DateFormat('d MMMM y').format(dateTime);

                return GestureDetector(
                  onLongPress: () {
                    showDeleteConfirmationDialog(doc.id, context, doc['image']);
                  },
                  child: Expanded(
                    // height: 270,
                    // width: 300,
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
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                               Text("name : ${doc['name']}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
