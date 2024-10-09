import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/HelperFunctions/Toast.dart';
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
  List<String?> _selectedTypeValues = [];
  bool isLoading = false;
  int _quantity = 0;
  String formattedDate = '';
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
      appBar: AppBar(
        title: Text(
          "Order Page",
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
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                buildTextFormField(
                  labelText: "Name",
                  keyboardType: TextInputType.name,
                  controller: _nameCtrl,
                ),
                buildTextFormField(
                  labelText: "Enter Phone Number",
                  keyboardType: TextInputType.phone,
                  controller: _phoneNumberCtrl,
                ),
                buildTextFormField(
                  labelText: "City",
                  keyboardType: TextInputType.name,
                  controller: _cityCtrl,
                ),
                buildTextFormField(
                  labelText: "Advance Gold",
                  keyboardType: TextInputType.number,
                  controller: _advanceGoldCtrl,
                ),
                buildTextFormField(
                  labelText: "Quantity",
                  keyboardType: TextInputType.number,
                  controller: _quantityCtrl,
                  onChanged: (value) {
                    setState(() {
                      _quantity = int.tryParse(value) ?? 0;
                      _updateDropdownFields();
                    });
                  },
                ),
                _buildDynamicFields(),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await _saveTransaction();

                    setState(() {
                      _quantity = 0;
                    });
                    ToastMessage.toast_("Data Saved.");
                    //navigating to homeScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecordsScreen()),
                    );
                  },
                  child: Text("Save Transaction"),
                ),
              ],
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

  // Method to build dynamic type fields based on the entered quantity
  Widget _buildDynamicFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _quantity; i++) {
      fields.add(_buildDropdownField(
        labelText: "Type ${i + 1}",
        value: _selectedTypeValues[i],
        items: _typeOptions,
        onChanged: (String? newValue) {
          setState(() {
            _selectedTypeValues[i] = newValue;
          });
        },
      ));
    }
    return Expanded(
      child: ListView(
        children: fields,
      ),
    );
  }

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
        ToastMessage.toast_('2');
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
      for (int i = 0; i < _quantity; i++) {
        final selectedType = _selectedTypeValues[i];
        final percentage = _typePercentageMap[selectedType ?? ''];

        typesAndPercentages.add({
          'type': selectedType,
          'percentage': percentage,
        });
      }
      bool doesUserExist = await checkCustmerExist(_phoneNumberCtrl.text);
      if (doesUserExist) {
        var length = await getDayPayables();
        var generatedBarCode = '$formattedDate-$length';
        print("generatedBar : $generatedBarCode");

        final weight = _advanceGoldCtrl.text;

        // Save data to Firestore
        await firestore
            .collection(Collectionnames.mainCollectionName)
            .doc(Collectionnames.dialyTransactionDoc)
            .collection(formattedDate)
            .add({
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
      _selectedTypeValues = [];

      isLoading = false;
      Navigator.of(context).pop();
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
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orangeAccent, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!, width: 2.0),
          borderRadius: BorderRadius.circular(10),
        ),
        labelText: labelText,
      ),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    ),
  );
}
