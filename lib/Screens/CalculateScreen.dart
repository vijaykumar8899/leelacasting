import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/CommonWidgets/InputField.dart';
import 'package:leelacasting/CommonWidgets/Loading.dart';
import 'package:leelacasting/CommonWidgets/SizedBoxAndBoldNormalText.dart';
import 'package:leelacasting/Screens/HomeScreen.dart';
import 'package:leelacasting/Screens/TabScreens.dart';
import 'package:leelacasting/Screens/TransactionSaveScreen.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:leelacasting/Utilites/Colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculateScreen extends StatefulWidget {
  String collectionPath;
  String docId;
  String history;
  String transaction;

  CalculateScreen(
      {super.key,
      required this.collectionPath,
      required this.docId,
      required this.history,
      required this.transaction});

  @override
  State<CalculateScreen> createState() => _CalculateScreenState();
}

class _CalculateScreenState extends State<CalculateScreen> {
  TextEditingController ornamentWeightCtrl = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  bool isLoading = false;
  double advanceGold = 0.0;
  double ornamentWeight = 0.0;
  bool showCalculationField = false;
  String percentage = '';
  double ornamentcostWithPer = 0.0;
  double resultMoney = 0.0;
  int todaysGoldPrice = 0;
  double pendingGold = 0.0;
  String payables = 'N';
  String receivables = 'N';
  String active = 'Y';
  String transactionClosed = 'N';
  bool transactionClosed_ = false;
  bool calculateToMoney_ = false;
  bool isHistory = false;
  bool isTransactionClosedByHistory = false;
  final _screenShotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    getFieldsToSharedPref();
    // print('history : ${widget.history}');
    // print("transaction: ${widget.transaction}");
    var history_ = int.parse(widget.history) ?? 0;
    if (history_ > 0) {
      setState(() {
        isHistory = true;
      });
    }
    if (widget.transaction == 'Y') {
      setState(() {
        isTransactionClosedByHistory = true;
      });
    }
  }

  Future<void> sendImageToWathsapp() async {
    final imageBytes = await _screenShotController.capture();

    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/screenshot.png';

    File tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(imageBytes!);

    // Use shareXFiles instead of shareFiles
    await Share.shareXFiles([XFile(tempFilePath)],
        text: 'Check out this screenshot!');

    // Delete the temporary file after sharing
    await tempFile.delete();
  }

  getFieldsToSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    advanceGold = prefs.getDouble('advanceGold') ?? 0.0;
    ornamentWeight = prefs.getDouble('ornamentWeight') ?? 0.0;
    percentage = prefs.getString('percentage') ?? '';
    todaysGoldPrice = prefs.getInt('todaysGoldPrice') ?? 0;
    if (ornamentWeight > 0.0) {
      setState(() {
        showCalculationField = true;
      });
    }

    print("percentage : $percentage");
    print("ornamentWeight : $ornamentWeight");
    print("advanceGold : $advanceGold");
    print('showCalculationField : $showCalculationField');
  }

  saveOrnamentWeightToFirebase() async {
    try {
      await firestore
          .collection(Collectionnames.mainCollectionName)
          .doc(Collectionnames.dialyTransactionDoc)
          .collection(widget.collectionPath)
          .doc(widget.docId)
          .update({'ornamentWeight': ornamentWeightCtrl.text});

      // calculatingAmount();
    } catch (e) {
      print("error in set : $e");
    }
  }

  calculatingAmount() {
    try {
      print("calculatingAmount");
      var percentage_ = double.parse(percentage);
      setState(() {
        ornamentcostWithPer = (ornamentWeight * percentage_) / 100;
        print("ornamentcostWithPer : $ornamentcostWithPer");
        if (advanceGold != 0.0) {
          pendingGold = ornamentcostWithPer - advanceGold;
        }
        if (isHistory) {
          var todaysGoldPrice_ = int.parse(widget.history) ?? 0;
          resultMoney = pendingGold * todaysGoldPrice_;
        } else {
          resultMoney = pendingGold * todaysGoldPrice;
        }

        if (pendingGold > 0.0) {
          setState(() {
            receivables = 'Y';
            payables = 'N';
            active = 'Y';
          });
        } else {
          setState(() {
            receivables = 'NA';
            payables = 'NA';
            active = 'N';
          });
        }
      });
    } catch (e) {
      print("error calculatingMoney $e");
    }
  }

  Widget displayAmount() {
    calculatingAmount();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: AppColors.secondaryClr,
        border: Border.all(
          color: Colors.white70,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextBoxNormal(
                text: ornamentWeight.toStringAsFixed(3),
              ),
              TextBoxNormal(text: " * "),
              TextBoxNormal(text: "$percentage%"),
            ],
          ),
          TextBoxNormal(
              text:
                  "= ${ornamentcostWithPer.toStringAsFixed(3)} - $advanceGold"),
          if (calculateToMoney_) ...[
            if (isHistory) ...[
              TextBoxNormal(
                  text:
                      "= ${pendingGold.toStringAsFixed(3)} * ${widget.history}"),
              TextBoxBold(text: "Total =  ${resultMoney.toStringAsFixed(0)}"),
            ] else ...[
              TextBoxNormal(
                  text:
                      "= ${pendingGold.toStringAsFixed(3)} * $todaysGoldPrice"),
              TextBoxBold(text: "Total =  ${resultMoney.toStringAsFixed(0)}"),
            ],
          ] else ...[
            TextBoxBold(text: "= ${pendingGold.toStringAsFixed(3)}"),
          ],
        ],
      ),
    );
  }

  Future<void> takeOrnamentWeight(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext outerContext) {
        return AlertDialog(
          title: const Text('Enter Ornament Weight'),
          actions: <Widget>[
            buildTextFormField(
              labelText: "Weight",
              keyboardType: TextInputType.number,
              controller: ornamentWeightCtrl,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    print("clicked");
                    setState(() {
                      isLoading = true;
                    });
                    await saveOrnamentWeightToFirebase();
                    setState(() {
                      var orWeight =
                          double.parse(ornamentWeightCtrl.text) ?? 1.0;
                      ornamentWeight = orWeight;
                      isLoading = false;
                    });
                    // getFieldsToSharedPref();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> saveFinalCalculationToFirebase() async {
    await firestore
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(widget.collectionPath)
        .doc(widget.docId)
        .update({
      'pendingGold': pendingGold.toString(),
      'payables': payables,
      'receivables': receivables,
      'todaysGoldPrice': todaysGoldPrice.toString(),
      'resultMoney': resultMoney.toString(),
      'active': active,
      'transactionClosed': transactionClosed,
      'timeStamp': Timestamp.now(),
    }).then((value) {
      print('Data Added.');
    }).catchError((error) {
      print('Error : $error');
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TabsScreen(),
      ),
    );
  }

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
      body: Stack(
        children: [
          Center(
            child: Screenshot(
              controller: _screenShotController,
              child: Column(
                children: [
                  FetchDataOfPaticularRecord(
                    collectionPath: widget.collectionPath,
                    docId: widget.docId,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (!isTransactionClosedByHistory) ...[
                    if (!showCalculationField) ...[
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     takeOrnamentWeight(context);
                      //   },
                      //   child: const Text('Enter Ornament Weight'),
                      // ),
                    ] else ...[
                      SizedBox(
                        height: 20,
                      ),
                      //calculating payables
                      displayAmount(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ],
                  // Text("transactionClosed_ : $transactionClosed_"),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      takeOrnamentWeight(context);
                    },
                    child: const Text('Enter Ornament Weight'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      TextBoxNormal(text: "Calculate to money : "),
                      Switch(
                        value: calculateToMoney_,
                        onChanged: (value) {
                          setState(() {
                            calculateToMoney_ = value;
                            // if (calculateToMoney_ == true) {
                            //   transactionClosed = "Y";
                            // } else {
                            //   transactionClosed = "N";
                            // }
                            // print("transactionClosed_ : $transactionClosed_");
                          });
                        },
                        activeColor: Colors.black, // Color when switch is on
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      TextBoxNormal(text: "Transaction Closed : "),
                      Switch(
                        value: transactionClosed_,
                        onChanged: (value) {
                          setState(() {
                            transactionClosed_ = value;
                            if (transactionClosed_ == true) {
                              transactionClosed = "Y";
                            } else {
                              transactionClosed = "N";
                            }
                            // print("transactionClosed_ : $transactionClosed_");
                          });
                        },
                        activeColor: Colors.black, // Color when switch is on
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await saveFinalCalculationToFirebase();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: const Text('Print Transction'),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) const LoadingIndicator(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          await sendImageToWathsapp();
          setState(() {
            isLoading = false;
          });
        },
        child: const Icon(FontAwesomeIcons.whatsapp),
      ),
    );
  }
}

class FetchDataOfPaticularRecord extends StatefulWidget {
  final String collectionPath;
  final String docId;

  FetchDataOfPaticularRecord(
      {super.key, required this.collectionPath, required this.docId});

  @override
  State<FetchDataOfPaticularRecord> createState() =>
      _FetchDataOfPaticularRecordState();
}

class _FetchDataOfPaticularRecordState
    extends State<FetchDataOfPaticularRecord> {
  double advanceGold = 0.0;
  double ornamentWeight = 0.0;
  String percentage = '';

  saveFieldsToSharedPref() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('advanceGold', advanceGold);
      await prefs.setDouble('ornamentWeight', ornamentWeight);
      await prefs.setString('percentage', percentage);
    } catch (e) {
      print("error in set : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a stream to listen to the document data.
    var stream_ = FirebaseFirestore.instance
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(widget.collectionPath) // Specify the collection
        .doc(widget.docId)
        .snapshots();

    return Container(
      // height: MediaQuery.of(context).size.height - 650,
      // width: MediaQuery.of(context).size.width - 20,

      child: StreamBuilder<DocumentSnapshot>(
        stream: stream_,
        builder: (context, snapshot) {
          // Check for error in snapshot
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Show loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const LoadingIndicator());
          }

          // Check if the snapshot has data and the document exists
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data available'));
          }

          // Extract document data
          var doc = snapshot.data!;
          Timestamp timeStamp = doc['timeStamp'] as Timestamp;
          DateTime dateTime = timeStamp.toDate();
          List<dynamic> typeAndPercentageList = doc['typeAndPercentage'];
          // var ornamentWeight_ = doc['ornamentWeight'];
          ornamentWeight = double.parse(doc['ornamentWeight']);
          advanceGold = double.parse(doc['advanceGold']);
          List<String> percentages = typeAndPercentageList
              .map((item) =>
                  item['percentage'] as String) // Adjust the type as necessary
              .toList();

// Access the first percentage
          if (percentages.isNotEmpty) {
            percentage = percentages[0];
          } else {
            print('No percentages found');
          }
          saveFieldsToSharedPref();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
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
                      barcode: Barcode.code128(), // Choose the barcode type
                      data: doc[
                          'generatedBarCode'], // The text to be converted into a barcode
                      width: 140,
                      height: 40,
                      drawText: true, // Display the text below the barcode
                    ),
                  ),
                ),

                SizedBox(height: 10),
                // Display the text as a label below the barcode

                Row(
                  children: [
                    TextBoxBold(text: "Customer Name :"),
                    SpaceBox(size: 20),
                    TextBoxNormal(
                      text: "${doc['name']}",
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextBoxBold(text: "City :"),
                    SpaceBox(size: 20),
                    TextBoxNormal(
                      text: "${doc['city']}",
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: typeAndPercentageList.map((item) {
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
                ] else ...[
                  Row(
                    children: [
                      TextBoxBold(text: "Type"),
                      SpaceBox(size: 20),
                      TextBoxNormal(
                        text: "${doc['type']}",
                      ),
                      TextBoxNormal(
                        text: "${doc['typeAndPercentage']}",
                      ),
                    ],
                  ),
                ],
                if (ornamentWeight > 0) ...[
                  Row(
                    children: [
                      TextBoxBold(text: "Ornament Weight"),
                      SpaceBox(size: 20),
                      TextBoxNormal(
                        text: "${doc['ornamentWeight']}",
                      ),
                    ],
                  ),
                ],
                if (doc['todaysGoldPrice'].toString() != '0') ...[
                  Row(
                    children: [
                      TextBoxBold(text: "Gold Rate :"),
                      SpaceBox(size: 20),
                      TextBoxNormal(
                        text: "${doc['todaysGoldPrice']}",
                      ),
                    ],
                  ),
                ],
                if (doc['pendingGold'].toString() != '0.000') ...[
                  Row(
                    children: [
                      TextBoxBold(text: "Pending Gold :"),
                      SpaceBox(size: 20),
                      TextBoxNormal(
                        text: "${doc['pendingGold']}",
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
