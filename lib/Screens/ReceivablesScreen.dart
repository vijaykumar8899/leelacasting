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

  static String? sharedPrefUser;
  String PhoneNumber = "";
}

class _ReceivablesScreenState extends State<ReceivablesScreen> {
  late SharedPreferences prefs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchAllDocuments();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAllDocuments() async {
    return await FirebaseFirestore.instance
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(Collectionnames.allDataCollection)
        .orderBy('timeStamp', descending: true)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 96, 66, 0),
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Receivables Page",
          style: GoogleFonts.spectralSc(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 96, 66, 0),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: fetchAllDocuments(),
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

                return Container(
                  child: Row(
                    children: [
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
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 0, 24, 50),
                const Color.fromARGB(255, 0, 18, 36)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.5),
                blurRadius: 0.0,
                spreadRadius: 0.0,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: const Color.fromARGB(255, 184, 182, 182),

              width: 1.5, // Adjusted width
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  widget.date,
                  style: GoogleFonts.mate(
                    fontSize: 18, // Increased font size
                    fontWeight: FontWeight.w600, // Bolder font weight
                    color: Colors.white,
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

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.spectralSc(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[300],
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          value ?? '',
          style: GoogleFonts.domine(
            textStyle: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

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
          padding: EdgeInsets.only(bottom: 10),
          width: MediaQuery.of(context).size.width - 30,
          height: MediaQuery.of(context).size.height - 800,
          margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 155, 155, 155),
              width: 2.0,
            ),
            color: Color.fromARGB(246, 2, 17, 34),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
              bottom: Radius.circular(20),
            ),
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
                            builder: (context) => MainHomeScreen2(
                                collectionPath: widget.collectionPath,
                                docId: doc.id)),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white,
                          width: 0,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://cdn.vectorstock.com/i/500p/81/36/luxury-black-gold-background-elegant-business-vector-52808136.jpg'),
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.black54,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 18.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white?.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  width: 170,
                                  height: 50,
                                  child: Center(
                                    child: BarcodeWidget(
                                      barcode: Barcode.code128(),
                                      data: doc['generatedBarCode'],
                                      width: 140,
                                      height: 45,
                                      drawText: true,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3),
                                _buildInfoRow(
                                    "Customer Name     : ", doc['name']),
                                _buildInfoRow(
                                    "City                             : ",
                                    doc['city']),
                                _buildInfoRow("Phone Number        : ",
                                    doc['phoneNumber']),
                                _buildInfoRow("Advance Gold         : ",
                                    doc['advanceGold']),
                                if (doc['typeAndPercentage'] is List) ...[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: typeAndPercentageList.map((item) {
                                      return _buildInfoRow("Type",
                                          "${item['type']} (${item['percentage']}%)");
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
                                    await Wathsapp
                                        .sendMessageToCustomerFromWhatsApp(
                                            doc['phoneNumber'], doc['name']);
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
                                          collectionPath: widget.collectionPath,
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
