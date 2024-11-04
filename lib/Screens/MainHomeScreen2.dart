import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/CommonWidgets/InputField.dart';
import 'package:leelacasting/CommonWidgets/SizedBoxAndBoldNormalText.dart';
import 'package:leelacasting/HelperFunctions/Toast.dart';
import 'package:leelacasting/Screens/TabScreens.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:leelacasting/Utilites/Colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../CommonWidgets/Loading.dart';

class MainHomeScreen2 extends StatefulWidget {
  String collectionPath;
  String docId;

  MainHomeScreen2({
    super.key,
    required this.collectionPath,
    required this.docId,
  });

  @override
  _MainHomeScreen2State createState() => _MainHomeScreen2State();
}

class _MainHomeScreen2State extends State<MainHomeScreen2> {
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
  int history_ = 0;
  String transction = '';
  bool isTransactionClosedByHistory = false;
  final _screenShotController = ScreenshotController();
  final GlobalKey _boundaryKey = GlobalKey();
  List<dynamic> typeAndPercentageList = [];
  List<String> percentages = [];

  @override
  void initState() {
    super.initState();
    getFieldsToSharedPref();
    // print('history : ${widget.history}');
    // print("transaction: ${widget.transaction}");
  }

  Future<void> sendImageToWathsapp() async {
    // final imageBytes = await _screenShotController.capture();
    // final tempDir = await getTemporaryDirectory();
    // final tempFilePath = '${tempDir.path}/screenshot.png';
    //
    // File tempFile = File(tempFilePath);
    // await tempFile.writeAsBytes(imageBytes!);
    //
    // // Use shareXFiles instead of shareFiles
    // await Share.shareXFiles([XFile(tempFilePath)],
    //     text: 'Check out this screenshot!');
    //
    // // Delete the temporary file after sharing
    // await tempFile.delete();
    try {
      RenderRepaintBoundary boundary = _boundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save image to file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/screenshot.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Share the file
      // await Share.shareFiles([file.path], text: 'Screenshot');
      await Share.shareXFiles([XFile(file.path)],
          text: 'From Leela Casting, Thank you!');
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  getFieldsToSharedPref() async {
    print("getFieldsToSharedPref");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    advanceGold = prefs.getDouble('advanceGold') ?? 0.0;
    ornamentWeight = prefs.getDouble('ornamentWeight') ?? 0.0;
    percentage = prefs.getString('percentage') ?? '';
    todaysGoldPrice = prefs.getInt('todaysGoldPrice') ?? 0;

    print("percentage : $percentage");
    print("ornamentWeight : $ornamentWeight");
    print("advanceGold : $advanceGold");
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
    print("calculatingAmount");
    // getFieldsToSharedPref();
    try {
      var percentage_ = double.parse(percentage) ?? 0.0;
      setState(() {
        ornamentcostWithPer = (ornamentWeight * percentage_) / 100;
        print("ornamentcostWithPer : $ornamentcostWithPer");
        if (advanceGold != 0.0) {
          pendingGold = ornamentcostWithPer - advanceGold;
        }
        if (isHistory) {
          var todaysGoldPrice_ = history_ ?? 0;
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
        } else if (pendingGold < 0.0) {
          setState(() {
            receivables = 'N';
            payables = 'Y';
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
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.all(Radius.circular(5)),
      //   color: AppColors.secondaryClr,
      //   border: Border.all(
      //     color: Colors.white70,
      //     width: 1.5,
      //   ),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextBoxNormal(
                text: "= ${ornamentWeight.toStringAsFixed(3)}",
              ),
              TextBoxNormal(text: " * "),
              TextBoxNormal(text: "$percentage%"),
            ],
          ),
          TextBoxNormal(
              text:
                  "= ${ornamentcostWithPer.toStringAsFixed(3)} - ${advanceGold.toStringAsFixed(3)}"),
          if (calculateToMoney_) ...[
            if (isHistory) ...[
              TextBoxNormal(
                  text: "= ${pendingGold.toStringAsFixed(3)} * ${history_}"),
              TextBoxBold(text: "Total =  ${resultMoney.toStringAsFixed(0)}"),
            ] else ...[
              TextBoxNormal(
                  text:
                      "= ${pendingGold.toStringAsFixed(3)} * $todaysGoldPrice"),
              TextBoxNormal(text: "Total =  ${resultMoney.toStringAsFixed(0)}"),
            ],
          ] else ...[
            TextBoxNormal(text: "= ${pendingGold.toStringAsFixed(3)}"),
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
                    // calculatingAmount();

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
    //first saving the data with resultMoney and payables or not etc;
    await firestore
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(widget.collectionPath)
        .doc(widget.docId)
        .update({
      'pendingGold': pendingGold.toStringAsFixed(3),
      'payables': payables,
      'receivables': receivables,
      'todaysGoldPrice': todaysGoldPrice.toString(),
      'resultMoney': resultMoney.toStringAsFixed(0),
      'active': active,
      'transactionClosed': transactionClosed,
      'timeStamp': Timestamp.now(),
    }).then((value) {
      print('Data Added.');
    }).catchError((error) {
      print('Error : $error');
    });

    //then fetching save record; saving in payables or recievables and then deleting original record.
    if (!transactionClosed_) {
      if (payables == 'Y') {
        try {
          DocumentSnapshot documentSnapshot = await firestore
              .collection(Collectionnames.mainCollectionName)
              .doc(Collectionnames.dialyTransactionDoc)
              .collection(widget.collectionPath)
              .doc(widget.docId)
              .get();

          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          await firestore
              .collection(Collectionnames.payablesCollectionName)
              .doc(Collectionnames.dialyTransactionDoc)
              .collection(widget.collectionPath)
              .doc(widget.docId)
              .set(data)
              .then((value) async {
            print('Document moved to new collection.');

            // Delete the document from the original collection
            await firestore
                .collection(Collectionnames.mainCollectionName)
                .doc(Collectionnames.dialyTransactionDoc)
                .collection(widget.collectionPath)
                .doc(widget.docId)
                .delete()
                .then((value) {
              print('Document deleted from original collection.');
            }).catchError((error) {
              print('Error deleting document: $error');
            });
          }).catchError((error) {
            print('Error moving document: $error');
          });
        } catch (e) {
          ToastMessage.toast_('error saving record $e');
        }
      } else if (receivables == 'Y') {
        try {
          DocumentSnapshot documentSnapshot = await firestore
              .collection(Collectionnames.mainCollectionName)
              .doc(Collectionnames.dialyTransactionDoc)
              .collection(widget.collectionPath)
              .doc(widget.docId)
              .get();

          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          await firestore
              .collection(Collectionnames.recivalbesCollectionName)
              .doc(Collectionnames.dialyTransactionDoc)
              .collection(widget.collectionPath)
              .doc(widget.docId)
              .set(data)
              .then((value) async {
            print('Document moved to new collection.');

            // Delete the document from the original collection
            await firestore
                .collection(Collectionnames.mainCollectionName)
                .doc(Collectionnames.dialyTransactionDoc)
                .collection(widget.collectionPath)
                .doc(widget.docId)
                .delete()
                .then((value) {
              print('Document deleted from original collection.');
            }).catchError((error) {
              print('Error deleting document: $error');
            });
          }).catchError((error) {
            print('Error moving document: $error');
          });
        } catch (e) {
          ToastMessage.toast_('error saving record $e');
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TabsScreen(),
      ),
    );
  }

  saveFieldsToSharedPref() async {
    print("saveFieldsToSharedPref");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('advanceGold', advanceGold);
      await prefs.setDouble('ornamentWeight', ornamentWeight);
      await prefs.setString('percentage', percentage);
    } catch (e) {
      print("error in set : $e");
    }
  }

  updateStateAndDataBasedOnFetchedResults(Map<String, dynamic> data) {
    Timestamp timeStamp =
    data['timeStamp'] as Timestamp;
    DateTime dateTime =
    timeStamp.toDate();
    typeAndPercentageList =
    data['typeAndPercentage'];
    // var ornamentWeight_ = doc['ornamentWeight'];
    ornamentWeight = double.parse(
        data['ornamentWeight']);
    advanceGold = double.parse(
        data['advanceGold']);
     percentages =
    typeAndPercentageList
        .map((item) => item[
    'percentage']
    as String) // Adjust the type as necessary
        .toList();
     print("typeAndPercentageList : $typeAndPercentageList");

    // Access the first percentage
    if (percentages.isNotEmpty) {
      percentage = percentages[0];
    } else {
      print('No percentages found');
    }
    saveFieldsToSharedPref();
    // getFieldsToSharedPref();
    // calculatingAmount();
    var transaction =
    data['transactionClosed'];
    history_ = int.parse(
        data['todaysGoldPrice']) ??
        0;
    if (history_ > 0) {
      setState(() {
        isHistory = true;
      });
    }
    if (transaction == 'Y') {
      setState(() {
        isTransactionClosedByHistory =
        true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 96, 66, 0),
      appBar: AppBar(
        title: Text(
          'Calculate Page',
          style: GoogleFonts.spectralSc(
            textStyle: TextStyle(
              fontSize: 20, // Set your desired font size
              fontWeight: FontWeight.bold,
              color: Colors.white, // Title color
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 96, 66, 0),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // _buildDetailedContainer(context),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: _boundaryKey,
                        child: Container(
                          padding: const EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color.fromARGB(255, 4, 52, 135)
                                    .withOpacity(0.2),
                                Colors.black,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://cdn.vectorstock.com/i/500p/81/36/luxury-black-gold-background-elegant-business-vector-52808136.jpg',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 18.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection(Collectionnames
                                                  .mainCollectionName)
                                              .doc(Collectionnames
                                                  .dialyTransactionDoc)
                                              .collection(widget
                                                  .collectionPath) // Specify the collection
                                              .doc(widget.docId)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator()); // Loading indicator
                                            }

                                            if (!snapshot.hasData ||
                                                !snapshot.data!.exists) {
                                              return Center(
                                                  child: Text(
                                                      "No data available"));
                                            }

                                            var data = snapshot.data!.data()
                                                as Map<String, dynamic>;

                                            Future.delayed(Duration.zero, () {
                                              updateStateAndDataBasedOnFetchedResults(data);
                                            });

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        ?.withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  width: 270,
                                                  height: 70,
                                                  child: Center(
                                                    child: BarcodeWidget(
                                                      barcode: Barcode
                                                          .code128(), // Choose the barcode type
                                                      data: data[
                                                          'generatedBarCode'], // The text to be converted into a barcode
                                                      width: 250,
                                                      height: 50,
                                                      drawText:
                                                          true, // Display the text below the barcode
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                _buildInfoRow(
                                                    "Customer Name       : ",
                                                    data['name']),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                    "City                               : ",
                                                    data['city']),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                    "Phone Number          : ",
                                                    data['phoneNumber']),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                    "Advance Gold           : ",
                                                    data['advanceGold']),
                                                const SizedBox(height: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children:
                                                        typeAndPercentageList
                                                            .map((item) {
                                                      return Row(
                                                        children: [
                                                          _buildInfoRow(
                                                              "Type                               : ",
                                                              "${item['type']} ${item['percentage']}%"),
                                                        ],
                                                      );
                                                    }).toList(),
                                                  ),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                    "Ornament Weight  : ",
                                                    data['ornamentWeight']),
                                                const SizedBox(height: 8),
                                                if (isHistory) ...[
                                                  _buildInfoRow(
                                                      "Gold Rate                   : ",
                                                      history_.toString()),
                                                ] else ...[
                                                  _buildInfoRow(
                                                      "Gold Rate                   : ",
                                                      todaysGoldPrice
                                                          .toString()),
                                                ],
                                                const SizedBox(height: 8),
                                                if (data['ornamentWeight']
                                                        .toString() !=
                                                    '0.000') ...[
                                                  _buildInfoRow(
                                                      "Pending Gold            : ",
                                                      data['pendingGold']),
                                                ] else ...[
                                                  _buildInfoRow(
                                                      "Pending Gold            : ",
                                                      pendingGold
                                                          .toStringAsFixed(3)),
                                                ],
                                              ],
                                            );
                                          }),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              await sendImageToWathsapp();
                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                            icon: Icon(
                                              FontAwesomeIcons.whatsapp,
                                              color: Colors.greenAccent[400],
                                              size: 70,
                                            ),
                                          ),
                                          const SizedBox(height: 35),
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Print',
                                                      style: GoogleFonts.lato(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Printing functionality goes here.',
                                                      style: GoogleFonts.lato(),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          'Close',
                                                          style:
                                                              GoogleFonts.lato(
                                                            color: Colors
                                                                .blueAccent,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                              FontAwesomeIcons.print,
                                              color: Color.fromARGB(
                                                  255, 0, 11, 39),
                                              size: 70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 150,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   children: [
                                    //     TextBoxNormal(
                                    //       text: ornamentWeight.toStringAsFixed(3),
                                    //     ),
                                    //     TextBoxNormal(text: " * "),
                                    //     TextBoxNormal(text: "$percentage%"),
                                    //   ],
                                    // ),
                                    // TextBoxNormal(
                                    //     text:
                                    //         "= ${ornamentcostWithPer.toStringAsFixed(3)} - $advanceGold"),
                                    // if (calculateToMoney_) ...[
                                    //   if (isHistory) ...[
                                    //     TextBoxNormal(
                                    //         text:
                                    //             "= ${pendingGold.toStringAsFixed(3)} * $history_"),
                                    //     TextBoxBold(
                                    //         text:
                                    //             "Total =  ${resultMoney.toStringAsFixed(0)}"),
                                    //   ] else ...[
                                    //     TextBoxNormal(
                                    //         text:
                                    //             "= ${pendingGold.toStringAsFixed(3)} * $todaysGoldPrice"),
                                    //     TextBoxNormal(
                                    //         text:
                                    //             "Total =  ${resultMoney.toStringAsFixed(0)}"),
                                    //   ],
                                    // ] else ...[
                                    //   TextBoxNormal(
                                    //       text:
                                    //           "= ${pendingGold.toStringAsFixed(3)}"),
                                    // ],
                                    displayAmount()
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Center(
                        child: Container(
                          height: 60, // Height for a more button-like feel
                          width: 250, // Fixed width
                          child: Material(
                            elevation: 10, // Elevation for depth
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            child: ElevatedButton(
                              onPressed: () {
                                takeOrnamentWeight(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 32, 58),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Rounded shape
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15), // Padding
                                shadowColor: Colors.black
                                    .withOpacity(0.5), // Shadow depth
                              ),
                              child: Text(
                                'Enter Ornament Weight',
                                style: GoogleFonts.domine(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15, // Font size
                                    fontWeight: FontWeight.bold, // Bold text
                                    letterSpacing: 1.2, // Letter spacing
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade900.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRowItem(
                              label: "Calculate to Money",
                              toggleValue: calculateToMoney_,
                              onToggleChanged: (value) {
                                setState(() {
                                  calculateToMoney_ = value;
                                  print("calculateToMoney_ $calculateToMoney_");
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.grey.shade700, thickness: 1),
                            SizedBox(height: 10),
                            _buildRowItem(
                              label: "Transaction Closed",
                              toggleValue: transactionClosed_,
                              onToggleChanged: (value) {
                                setState(() {
                                  transactionClosed_ = value;
                                  print(
                                      'isTransactionClosedOn $transactionClosed_');
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: Container(
                          height:
                              80, // Increased height for a more button-like feel
                          width: 950, // Fixed width to make it more button-like
                          child: Material(
                            elevation:
                                30, // Added elevation for a pronounced effect
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            child: ElevatedButton(
                              onPressed: () async {
                                print("Button clicked!");
                                setState(() {
                                  isLoading = true;
                                });
                                await saveFinalCalculationToFirebase();
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 29, 53),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15), // Increased padding
                                shadowColor: Colors.black.withOpacity(
                                    0.5), // Shadow color for more depth
                              ),
                              child: Text(
                                'Print Transaction',
                                style: GoogleFonts.domine(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        25, // Increased font size for better visibility
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) const LoadingIndicator(),
        ],
      ),
    );
  }

  // Widget _buildDetailedContainer(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(0.0),
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: [
  //                 const Color.fromARGB(255, 4, 52, 135).withOpacity(0.2),
  //                 Colors.black,
  //               ],
  //               begin: Alignment.topLeft,
  //               end: Alignment.bottomRight,
  //             ),
  //             border: Border.all(color: Colors.white, width: 1),
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           child: Column(
  //             children: [
  //               Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(30),
  //                   image: const DecorationImage(
  //                     image: NetworkImage(
  //                       'https://cdn.vectorstock.com/i/500p/81/36/luxury-black-gold-background-elegant-business-vector-52808136.jpg',
  //                     ),
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       vertical: 20.0, horizontal: 18.0),
  //                   child: Row(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Container(
  //                             decoration: BoxDecoration(
  //                               color: Colors.grey[800]?.withOpacity(0.8),
  //                               borderRadius: BorderRadius.circular(10.0),
  //                             ),
  //                             width: 230,
  //                             height: 40,
  //                             child: Center(
  //                               child: Text(
  //                                 'Barcode here',
  //                                 style: GoogleFonts.spectralSc(
  //                                   textStyle: const TextStyle(
  //                                     fontWeight: FontWeight.w500,
  //                                     color: Colors.white,
  //                                     fontSize: 16,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(height: 16),
  //                           _buildInfoRow("Customer Name       : ", 'name'),
  //                           const SizedBox(height: 8),
  //                           _buildInfoRow(
  //                               "City                               : ",
  //                               'city'),
  //                           const SizedBox(height: 8),
  //                           _buildInfoRow(
  //                               "Phone Number          : ", 'phoneNumber'),
  //                           const SizedBox(height: 8),
  //                           _buildInfoRow(
  //                               "Advance Gold           : ", 'advanceGold'),
  //                           const SizedBox(height: 16),
  //                           _buildInfoRow(
  //                               "Type                               : ",
  //                               'Molding, Casting 100%'),
  //                           const SizedBox(height: 8),
  //                           _buildInfoRow("Ornament Weight  : ", '3'),
  //                           const SizedBox(height: 8),
  //                           _buildInfoRow(
  //                               "Gold Rate                   : ", '7800'),
  //                           const SizedBox(height: 8),
  //                           _buildInfoRow("Pending Gold            : ", '1.0'),
  //                         ],
  //                       ),
  //                       Column(
  //                         children: [
  //                           IconButton(
  //                             onPressed: () {
  //                               // WhatsApp logic
  //                             },
  //                             icon: Icon(
  //                               FontAwesomeIcons.whatsapp,
  //                               color: Colors.greenAccent[400],
  //                               size: 70,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 35),
  //                           IconButton(
  //                             onPressed: () {
  //                               showDialog(
  //                                 context: context,
  //                                 builder: (BuildContext context) {
  //                                   return AlertDialog(
  //                                     title: Text(
  //                                       'Print',
  //                                       style: GoogleFonts.lato(
  //                                         fontWeight: FontWeight.bold,
  //                                       ),
  //                                     ),
  //                                     content: Text(
  //                                       'Printing functionality goes here.',
  //                                       style: GoogleFonts.lato(),
  //                                     ),
  //                                     actions: [
  //                                       TextButton(
  //                                         onPressed: () {
  //                                           Navigator.of(context).pop();
  //                                         },
  //                                         child: Text(
  //                                           'Close',
  //                                           style: GoogleFonts.lato(
  //                                             color: Colors.blueAccent,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   );
  //                                 },
  //                               );
  //                             },
  //                             icon: const Icon(
  //                               FontAwesomeIcons.print,
  //                               color: Color.fromARGB(255, 0, 11, 39),
  //                               size: 70,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Container(
  //                 height: 150,
  //                 alignment: Alignment.center,
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "   3000 × 100%",
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: const Color.fromARGB(221, 207, 207, 207),
  //                       ),
  //                     ),
  //                     SizedBox(height: 8),
  //                     Text(
  //                       "=  3.000 - 2.0",
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: const Color.fromARGB(221, 207, 207, 207),
  //                       ),
  //                     ),
  //                     SizedBox(height: 8),
  //                     Text(
  //                       "=      1.000",
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.green,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 50),
  //         Center(
  //           child: Container(
  //             height: 60, // Height for a more button-like feel
  //             width: 250, // Fixed width
  //             child: Material(
  //               elevation: 10, // Elevation for depth
  //               borderRadius: BorderRadius.circular(10), // Rounded corners
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   // Action when the button is clicked
  //                   print("Button clicked!");
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color.fromARGB(255, 0, 32, 58),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10), // Rounded shape
  //                   ),
  //                   padding: EdgeInsets.symmetric(
  //                       horizontal: 10, vertical: 15), // Padding
  //                   shadowColor: Colors.black.withOpacity(0.5), // Shadow depth
  //                 ),
  //                 child: Text(
  //                   'Enter Ornament Weight',
  //                   style: GoogleFonts.domine(
  //                     textStyle: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 15, // Font size
  //                       fontWeight: FontWeight.bold, // Bold text
  //                       letterSpacing: 1.2, // Letter spacing
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 30),
  //         Container(
  //           padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //           decoration: BoxDecoration(
  //             color: Colors.black,
  //             borderRadius: BorderRadius.circular(15),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.shade900.withOpacity(0.5),
  //                 blurRadius: 10,
  //                 spreadRadius: 2,
  //                 offset: Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               _buildRowItem(
  //                 label: "Calculate to Money",
  //                 toggleValue: calculateToMoney_,
  //                 onToggleChanged: (value) {
  //                   setState(() {
  //                     calculateToMoney_ = value;
  //                     print("calculateToMoney_ : $calculateToMoney_");
  //                   });
  //                 },
  //               ),
  //               SizedBox(height: 10),
  //               Divider(color: Colors.grey.shade700, thickness: 1),
  //               SizedBox(height: 10),
  //               _buildRowItem(
  //                 label: "Transaction Closed",
  //                 toggleValue: transactionClosed_,
  //                 onToggleChanged: (value) {
  //                   setState(() {
  //                     transactionClosed_ = value;
  //                     if (transactionClosed_ == true) {
  //                       transactionClosed = "Y";
  //                     } else {
  //                       transactionClosed = "N";
  //                     }
  //                     // print("transactionClosed_ : $transactionClosed_");
  //                   });
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //         SizedBox(height: 30),
  //         Center(
  //           child: Container(
  //             height: 80, // Increased height for a more button-like feel
  //             width: 950, // Fixed width to make it more button-like
  //             child: Material(
  //               elevation: 30, // Added elevation for a pronounced effect
  //               borderRadius: BorderRadius.circular(10), // Rounded corners
  //               child: ElevatedButton(
  //                 onPressed: () async {},
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color.fromARGB(255, 0, 29, 53),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   padding: EdgeInsets.symmetric(
  //                       horizontal: 10, vertical: 15), // Increased padding
  //                   shadowColor: Colors.black
  //                       .withOpacity(0.5), // Shadow color for more depth
  //                 ),
  //                 child: Text(
  //                   'Print Transaction',
  //                   style: GoogleFonts.domine(
  //                     textStyle: TextStyle(
  //                       color: Colors.white,
  //                       fontSize:
  //                           25, // Increased font size for better visibility
  //                       fontWeight: FontWeight.bold,
  //                       letterSpacing: 1.2,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.spectralSc(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.domine(
            textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRowItem({
    required String label,
    required bool toggleValue,
    required Function(bool) onToggleChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spectralSc(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        Switch(
          value: toggleValue,
          onChanged: onToggleChanged,
          activeColor: Colors.greenAccent,
          inactiveThumbColor: Colors.red,
          inactiveTrackColor: Colors.red.shade200,
        ),
      ],
    );
  }
}
