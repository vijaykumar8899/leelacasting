import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/CommonWidgets/InputField.dart';
import 'package:leelacasting/CommonWidgets/Loading.dart';
import 'package:leelacasting/HelperFunctions/Toast.dart';
import 'package:leelacasting/HelperFunctions/Wathsapp.dart';
import 'package:leelacasting/Screens/CalculateScreen.dart';
import 'package:leelacasting/Screens/GoldRateInput.dart';
import 'package:leelacasting/Screens/MainHomeScreen2.dart';
import 'package:leelacasting/Screens/TransactionSaveScreen.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:leelacasting/Utilites/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../CommonWidgets/SizedBoxAndBoldNormalText.dart';
import '../CommonWidgets/TransctionDialog.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:share_plus/share_plus.dart';

class ReceivablesScreen extends StatefulWidget {
  @override
  State<ReceivablesScreen> createState() => _ReceivablesScreenState();

  static String? sharedPrefUserPhoneNumber = "";
}

class _ReceivablesScreenState extends State<ReceivablesScreen> {
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

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Receivables Page",
          style: GoogleFonts.rowdies(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryClr,
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: fetchAllDocumentSnapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: const LoadingIndicator(),
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

                // print(ReceivablesScreen.numberOfArrowIcons);
                // String totalWeight = documentData['totalWeight'];
                // print('document : $document');

                // Display the document ID and its data
                return Container(
                  child: Row(
                    children: [
                      // Left container occupying 3/4th of the width
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Column(
                            children: [
                              DisplayDataFromFirebase(
                                  collectionPath: documentID),
                            ],
                          ),
                        ),
                      ),
                      // Right container occupying 1/4th of the width
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: DayDisplayContainer(
                            date: documentID,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
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
          height: MediaQuery.of(context).size.height * 0.04,
          width: MediaQuery.of(context).size.width - 40,
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
  bool isLoading = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    var stream_ = FirebaseFirestore.instance
        .collection(Collectionnames.recivalbesCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(widget.collectionPath)
        .orderBy('timeStamp', descending: true)
        .snapshots();

    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width - 30,
          height: MediaQuery.of(context).size.height - 800,
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
                return const Center(child: const LoadingIndicator());
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
                            builder: (context) =>
                                MainHomeScreen2(
                                    collectionPath:
                                    widget.collectionPath,
                                    docId: doc.id)),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side:
                              const BorderSide(width: 2.0, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BarcodeWidget(
                                    barcode: Barcode
                                        .code128(), // Choose the barcode type
                                    data: doc[
                                        'generatedBarCode'], // The text to be converted into a barcode
                                    width: 250,
                                    height: 50,
                                    drawText:
                                        true, // Display the text below the barcode
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      TextBoxBold(text: "Customer Name "),
                                      SpaceBox(size: 20),
                                      TextBoxNormal(
                                        text: ": ${doc['name']}",
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextBoxBold(text: "City "),
                                      SpaceBox(size: 60),
                                      TextBoxNormal(
                                        text: ": ${doc['city']}",
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      TextBoxBold(text: "PhoneNumber"),
                                      SpaceBox(size: 20),
                                      TextBoxNormal(
                                        text: "${doc['phoneNumber']}",
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      TextBoxBold(text: "Advance Gold :"),
                                      SpaceBox(size: 20),
                                      TextBoxNormal(
                                        text: "${doc['advanceGold']}",
                                      ),
                                    ],
                                  ),
                                  if (doc['typeAndPercentage'] is List) ...[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          typeAndPercentageList.map((item) {
                                        return Row(
                                          children: [
                                            TextBoxBold(text: "Type : "),
                                            SpaceBox(size: 20),
                                            TextBoxNormal(
                                              text: "${item['type']} ",
                                            ),
                                            TextBoxNormal(
                                              text: "${item['percentage']}%",
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      // Capture screenshot and save it
                                      // await captureAndSaveScreenshot();

                                      await Wathsapp
                                          .sendMessageToCustomerFromWhatsApp(
                                              doc['phoneNumber'], doc['name']);

                                      // await sendImageToWathsapp();
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    icon: const Icon(FontAwesomeIcons.whatsapp),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return TransactionDialog(
                                            collectionPath:
                                                widget.collectionPath,
                                            docId: doc.id,
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(FontAwesomeIcons.print),
                                  ),
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
        if (isLoading) const LoadingIndicator(),
      ],
    );
  }
}
