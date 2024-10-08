import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/CommonWidgets/InputField.dart';
import 'package:leelacasting/CommonWidgets/Loading.dart';
import 'package:leelacasting/Screens/CalculateScreen.dart';
import 'package:leelacasting/Screens/GoldRateInput.dart';
import 'package:leelacasting/Screens/TransactionSaveScreen.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:leelacasting/Utilites/Colors.dart';

import 'package:shared_preferences/shared_preferences.dart';

class RecordsScreen extends StatefulWidget {
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();

  static String? sharedPrefUserPhoneNumber = "";
}

class _RecordsScreenState extends State<RecordsScreen> {
  late SharedPreferences prefs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchAllDocuments();
  }

  Future<QuerySnapshot<Map<String, dynamic>>>
      fetchAllDocumentSnapshots() async {
    return await FirebaseFirestore.instance
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(Collectionnames.allDataCollection)
        .orderBy('timeStamp', descending: true)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAllDocuments() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(Collectionnames.allDataCollection)
        .orderBy('timeStamp', descending: true)
        .get();

    // Initialize the arrow count with the snapshot length

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Home Page",
          style: GoogleFonts.rowdies(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(FontAwesomeIcons.bars),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.barcode),
              onPressed: () async {},
            ),
          ),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryClr,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryClr,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle the Home tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle the Settings tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_page),
              title: Text('Contact'),
              onTap: () {
                // Handle the Contact tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            //bluetooth
            ListTile(
              leading: Icon(Icons.bluetooth_rounded),
              title: Text('Bluetooth Printer'),
              onTap: () {
                // Handle the Contact tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            //Gold Rate update
            ListTile(
              leading: Icon(Icons.currency_rupee_sharp),
              title: Text("Today's Gold Rate"),
              onTap: () async{
                await GoldRateInput();
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
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

                // print(RecordsScreen.numberOfArrowIcons);
                // String totalWeight = documentData['totalWeight'];
                // print('document : $document');

                // Display the document ID and its data
                return Column(
                  children: [
                    DayDisplayContainer(
                      date: documentID,
                    ),
                    DisplayDataFromFirebase(collectionPath: documentID)
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

class DayDisplayContainer extends StatefulWidget {
  final String date;

  const DayDisplayContainer({
    required this.date,
    Key? key,
  }) : super(key: key);

  @override
  State<DayDisplayContainer> createState() => _DayDisplayContainerState();
}

class _DayDisplayContainerState extends State<DayDisplayContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height - 780,
          width: MediaQuery.of(context).size.width - 100,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: AppColors.secondaryClr,
            border: Border.all(
              color: Colors.white70,
              width: 1.5,
            ),
          ),
          // color: Colors.blue,
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  widget.date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DisplayDataFromFirebase extends StatefulWidget {
  final String collectionPath;

  DisplayDataFromFirebase({Key? key, required this.collectionPath})
      : super(key: key);

  @override
  State<DisplayDataFromFirebase> createState() =>
      _DisplayDataFromFirebaseState();
}

class _DisplayDataFromFirebaseState extends State<DisplayDataFromFirebase> {
  TextEditingController ornamentWeightCtrl = TextEditingController();
  bool isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    var stream_ = FirebaseFirestore.instance
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(widget.collectionPath)
        .where('active', isEqualTo: "Y")
        .snapshots();

    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 30,
          height: MediaQuery.of(context).size.height - 300,
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
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  var doc = snapshot.data!.docs[index];
                  Timestamp timeStamp = doc['timeStamp'] as Timestamp;
                  DateTime dateTime = timeStamp.toDate();
                  List<dynamic> typeAndPercentageList =
                      doc['typeAndPercentage'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalculateScreen(
                                  collectionPath: widget.collectionPath,
                                  docId: doc.id,
                                )),
                      );
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(width: 2.0, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("Name : ${doc['name']}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("City : ${doc['city']}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        "Phone Number : ${doc['phoneNumber']}"),
                                  ],
                                ),
                                if (doc['typeAndPercentage'] is List) ...[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: typeAndPercentageList.map((item) {
                                      return Row(
                                        children: [
                                          Text("Type: ${item['type']}"),
                                          SizedBox(width: 10),
                                          Text(
                                              "Percentage: ${item['percentage']}%"),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ] else ...[
                                  Text(
                                      "typeAndPercentage: ${doc['typeAndPercentage']}"),
                                ]
                              ],
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(FontAwesomeIcons.arrowDown),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (isLoading) const LoadingIndicator(),
      ],
    );
  }
}
