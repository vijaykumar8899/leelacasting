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
import 'package:leelacasting/Screens/TransactionSaveScreen.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:leelacasting/Utilites/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculateScreen extends StatefulWidget {
  String collectionPath;
  String docId;

  CalculateScreen(
      {super.key, required this.collectionPath, required this.docId});

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

  @override
  void initState() {
    super.initState();
    getFieldsToSharedPref();
  }

  getFieldsToSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    advanceGold = prefs.getDouble('advanceGold') ?? 0.0;
    ornamentWeight = prefs.getDouble('ornamentWeight') ?? 0.0;
    percentage = prefs.getString('percentage') ?? '';
    todaysGoldPrice = prefs.getInt('todaysGoldPrice') ?? 0;
    if(ornamentWeight > 0.0){
      setState(() {
        showCalculationField=true;
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
        resultMoney = ornamentcostWithPer * todaysGoldPrice;
      });
    }catch(e){
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
          TextBoxNormal(text: "= ${ornamentcostWithPer.toStringAsFixed(3)} * $todaysGoldPrice"),
          TextBoxBold(text: "Total =  ${resultMoney.toStringAsFixed(0)}"),
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
                      isLoading = false;
                    });
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

  void initializeMethods() async{
   await getFieldsToSharedPref();
    await calculatingAmount();
  }

  // Widget dummy() {
  //   print('in dummy');
  //   initializeMethods();
  //   return SizedBox(height: 5,);
  // }

  Future<void> saveFinalCalculationToFirebase() async{
    await firestore
        .collection(Collectionnames.mainCollectionName)
        .doc(Collectionnames.dialyTransactionDoc)
        .collection(formattedDate)
        .doc(length.toString())
        .set({
      'name': _nameCtrl.text,
      'phoneNumber': _phoneNumberCtrl.text,
      'city': _cityCtrl.text,
      'generatedBarCode': generatedBarCode,
      'advanceGold': weight.toString(),
      'typeAndPercentage': typesAndPercentages,
      'ornamentWeight': '0.000',
      'pendingGold': '0.000',
      'payables': 'NA',
      'receivables': 'NA',
      'active': 'Y',
      'transactionClosed': 'N',
      'timeStamp': Timestamp.now(),
    }).then((value) {
      print('Data Added.');
    }).catchError((error) {
      print('Error : $error');
    });
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
            child: Column(
              children: [
                FetchDataOfPaticularRecord(
                  collectionPath: widget.collectionPath,
                  docId: widget.docId,
                ),

                SizedBox(height: 20,),
                if (!showCalculationField) ...[
                  ElevatedButton(
                    onPressed: () async {
                      takeOrnamentWeight(context);
                    },
                    child: const Text('Enter Ornament Weight'),
                  ),
                ] else ...[
                SizedBox(height: 20,),
                //calculating payables
                displayAmount(),
                  SizedBox(height: 20,),

                  ElevatedButton(
                    onPressed: () async {
                     await saveFinalCalculationToFirebase();
                    },
                    child: const Text('Print'),
                  ),                ],
              ],
            ),
          ),
          if (isLoading) const LoadingIndicator(),
        ],
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
      color: Colors.red,
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
          List<dynamic> typeAndPercentageList = doc['typeAndPercentage'];
          var ornamentWeight_ = doc['ornamentWeight'];
          ornamentWeight = double.parse(ornamentWeight_);
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
                    BarcodeWidget(
                      barcode: Barcode.code128(), // Choose the barcode type
                      data: doc[
                          'generatedBarCode'], // The text to be converted into a barcode
                      width: 250,
                      height: 50,
                      drawText: true, // Display the text below the barcode
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CalculatingPayablesAndRecivables extends StatelessWidget {
  const CalculatingPayablesAndRecivables({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
