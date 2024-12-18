import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/CommonWidgets/TransctionDialog.dart';
import 'package:leelacasting/HelperFunctions/Toast.dart';
import 'package:leelacasting/Screens/CalculateScreen.dart';
import 'package:leelacasting/Screens/HomeScreen.dart';
import 'package:leelacasting/Screens/RecordScreen.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:leelacasting/Utilites/Colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leelacasting/CommonWidgets/InputField.dart';

class TransactionSaveScreen extends StatefulWidget {
  const TransactionSaveScreen({super.key});

  @override
  State<TransactionSaveScreen> createState() => _TransactionSaveScreenState();
}

class _TransactionSaveScreenState extends State<TransactionSaveScreen> {
  TextEditingController _phoneNumberCtrl = TextEditingController();
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _cityCtrl = TextEditingController();
  TextEditingController _quantityCtrl = TextEditingController();
  TextEditingController _advanceGoldCtrl = TextEditingController();

  // Lists to store selected values
  // List<String?> _selectedTypeValues = [];
  List<String?> _selectedTypeValues = List.generate(1, (index) => null);
  bool isLoading = false;
  int _quantity = 0;
  String formattedDate = '';
  var length;
  double totalPayablesOfDay = 0.0;
  double totalRecivablesOfDay = 0.0;

  // Example type and percentage options
  final List<String> _typeOptions = [
    'Designing Wax',
    'Molding, Casting',
    'Finishing'
  ];
// Map to link type with corresponding percentage
  final Map<String, String> _typePercentageMap = {
    'Designing Wax': '99',
    'Molding, Casting': '100',
    'Finishing': '102',
  };
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    timeAndDate();
  }

  Future<void> timeAndDate() async {
    String currentDate = DateTime.now()
        .toString()
        .split(' ')[0]; // Get today's date in format 'yyyy-mm-dd'

    List<String> parts = currentDate.split('-');
    formattedDate = '${parts[2]}-${parts[1]}-${parts[0]}';
    // Reversing the date format to 'dd-mm-yyyy'
    // formattedDate = '06-10-2024';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 96, 66, 0),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 96, 66, 0),
        title: Text(
          'Leela Casting',
          style: GoogleFonts.spectralSc(
            textStyle: TextStyle(
              fontSize: 30, // Set your desired font size
              fontWeight: FontWeight.bold,
              color: Colors.white, // Title color
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
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.9, // Make the container responsive
              padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20), // Adjusted padding for title space
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 4, 52, 135).withOpacity(0.2),
                    Colors.black
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black87.withOpacity(0.5),
                //     spreadRadius: 4,
                //     blurRadius: 15,
                //     offset: const Offset(3, 8),
                //   ),
                // ],
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Adjusts the height based on content
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Aligns title to start
                children: [
                  // Title at the top
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 50.0,
                      top: 20,
                    ), // Space below title
                    child: Center(
                      child: Text(
                        "Enter Order Details",
                        style: GoogleFonts.spectralSc(
                          textStyle: TextStyle(
                            fontSize: 30, // Set your desired font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Title color
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Form fields
                  buildTextFormField(
                    labelText: "Name",
                    keyboardType: TextInputType.name,
                    controller: _nameCtrl,
                  ),
                  SizedBox(height: 20), // Spacing between fields
                  buildTextFormField(
                    labelText: "Enter Phone Number",
                    keyboardType: TextInputType.phone,
                    controller: _phoneNumberCtrl,
                  ),
                  SizedBox(height: 20),
                  buildTextFormField(
                    labelText: "City",
                    keyboardType: TextInputType.name,
                    controller: _cityCtrl,
                  ),
                  SizedBox(height: 20),
                  buildTextFormField(
                    labelText: "Advance Gold",
                    keyboardType: TextInputType.number,
                    controller: _advanceGoldCtrl,
                  ),
                  SizedBox(height: 20),
                  _buildDropdownField(
                    labelText: "Select Type",
                    items: _typeOptions,
                    value: _selectedTypeValues[0],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTypeValues[0] = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 50), // Space before button

                  // Save Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 1, 72, 86), // Button color
                        padding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (_nameCtrl.text.isNotEmpty &&
                            _phoneNumberCtrl.text.isNotEmpty &&
                            _cityCtrl.text.isNotEmpty &&
                            _advanceGoldCtrl.text.isNotEmpty &&
                            _selectedTypeValues.isNotEmpty) {
                          await _saveTransaction();
                          setState(() {
                            _quantity = 1;
                            isLoading = false;
                          });
                          ToastMessage.toast_("Data Saved.");
                          // Navigating to homeScreen
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TransactionDialog(
                                collectionPath: formattedDate,
                                docId: length.toString(),
                              );
                            },
                          );
                        } else {
                          ToastMessage.toast_('Enter all fields.');
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Text(
                        "Save Transaction",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(250, 255, 249, 249),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: SpinKitFadingCube(
              size: 60,
              itemBuilder: (context, index) {
                final colors = [Colors.orangeAccent, Colors.black];
                final color = colors[index % colors.length];

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // displayTransactionCopy(){
  //   FetchDataOfPaticularRecord(
  //     collectionPath: collection,
  //     docId: widget.docId,
  //   ),
  // }

  // Method to build dynamic type fields based on the entered quantity
  // Widget _buildDynamicFields() {
  //   List<Widget> fields = [];
  //   for (int i = 0; i < _quantity; i++) {
  //     fields.add(_buildDropdownField(
  //       labelText: "Type ${i + 1}",
  //       value: _selectedTypeValues[i],
  //       items: _typeOptions,
  //       onChanged: (String? newValue) {
  //         setState(() {
  //           _selectedTypeValues[i] = newValue;
  //         });
  //       },
  //     ));
  //   }
  //   return Expanded(
  //     child: ListView(
  //       children: fields,
  //     ),
  //   );
  // }

  // Method to update dropdown field lists when quantity changes
  void _updateDropdownFields() {
    _selectedTypeValues = List.generate(_quantity, (index) => null);
  }

  Future<bool> checkCustmerExist(String phoneNumber) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await firestore.collection('customerList').doc(phoneNumber).get();

      if (docSnapshot.exists) {
        return true;
      } else {
        try {
          await firestore.collection('customerList').doc(phoneNumber).set({
            'customerName': _nameCtrl.text,
            'customerPhoneNumber': phoneNumber,
            'customerCity': _cityCtrl.text,
            'timeStamp': Timestamp.now(),
          });
        } catch (e) {
          print("error in set : $e");
        }
        return true;
      }
    } catch (e) {
      print("error checkCustmer : $e");
    }
    return false;
  }

  Future<int> getDayPayables() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await firestore
          .collection(Collectionnames.mainCollectionName)
          .doc(Collectionnames.dialyTransactionDoc)
          .collection(Collectionnames.allDataCollection)
          .doc(formattedDate)
          .get();

      if (docSnapshot.exists) {
        // Access the totalWeight and totalCount fields from the document
        print(' data from fire : ${docSnapshot.data()}');
        // print(
        //     ' data from str : ${docSnapshot.data()?['totalWeight'].toString()}');

        String totalPayablesOfDay_ = docSnapshot.data()!['totalPayablesOfDay'];
        String totalRecivablesOfDay_ =
            docSnapshot.data()!['totalRecivablesOfDay'];
        // ToastMessage.toast_('2');
        totalPayablesOfDay = double.tryParse(totalPayablesOfDay_) ?? 0.0;
        totalRecivablesOfDay = double.tryParse(totalRecivablesOfDay_) ?? 0.0;
        try {
          QuerySnapshot<Map<String, dynamic>> dayData = await firestore
              .collection(Collectionnames.mainCollectionName)
              .doc(Collectionnames.dialyTransactionDoc)
              .collection(formattedDate)
              .get();

          if (dayData.docs.isNotEmpty) {
            var length = dayData.docs.length;
            print("length : $length");
            return length;
          } else {
            print("No doc so length is 0");
          }
        } catch (e) {
          print("error at dataData fetch : $e");
        }
      } else {
        try {
          await firestore
              .collection(Collectionnames.mainCollectionName)
              .doc(Collectionnames.dialyTransactionDoc)
              .collection(Collectionnames.allDataCollection)
              .doc(formattedDate)
              .set({
            'totalPayablesOfDay': '0.000',
            'totalRecivablesOfDay': '0.000',
            'timeStamp': Timestamp.now(),
          });
        } catch (e) {
          print("error in set : $e");
        }
      }
    } catch (e) {
      print('Error in the first method : $e');
    }
    return 0;
  }

  // Method to save the transaction data
  Future<void> _saveTransaction() async {
    try {
      List<Map<String, String?>> typesAndPercentages = [];

      // for (int i = 0; i < _quantity; i++) {
      //   final selectedType = _selectedTypeValues[i];
      //   final percentage = _typePercentageMap[selectedType ?? ''];
      //
      //   typesAndPercentages.add({
      //     'type': selectedType,
      //     'percentage': percentage,
      //   });
      // }_
      final selectedType = _selectedTypeValues[0];
      final percentage = _typePercentageMap[selectedType ?? ''];
      typesAndPercentages.add({
        'type': selectedType,
        'percentage': percentage,
      });
      bool doesUserExist = await checkCustmerExist(_phoneNumberCtrl.text);
      if (doesUserExist) {
        length = await getDayPayables();
        var generatedBarCode = '$formattedDate-$length';
        print("generatedBar : $generatedBarCode");

        final weight = _advanceGoldCtrl.text;

        // Save data to Firestore
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
          'resultMoney': '0',
          'todaysGoldPrice': '0',
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
      } else {
        ToastMessage.toast_(
            'Something went wrong, Please try after some time : userCheck');
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      _nameCtrl.clear();
      _phoneNumberCtrl.clear();
      _cityCtrl.clear();
      _advanceGoldCtrl.clear();

      isLoading = false;
    });
  }
}

// Dropdown field builder
Widget _buildDropdownField({
  required String labelText,
  required List<String> items,
  String? value,
  required ValueChanged<String?> onChanged,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 50),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 0, 0, 0),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: const Color.fromARGB(147, 255, 172, 64), width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: const Color.fromARGB(255, 88, 88, 88), width: 2.0),
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: labelText,
          labelStyle: TextStyle(
            color: const Color.fromARGB(
                255, 146, 146, 146), // Set your desired label text color here
          ),
        ),
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
