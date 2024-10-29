import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leelacasting/Utilites/CollectionNames.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../CommonWidgets/Loading.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  late SharedPreferences prefs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> dates = [];

  String? selectedDate;
  bool isRightPanelOpen = true; // State variable to manage the right panel

  // Mock data for items corresponding to each date
  final Map<String, List<Map<String, String>>> dateDetails = {
    '2024-10-01': [
      {
        'name': 'Alice',
        'city': 'New York',
        'phoneNumber': '123-456-7890',
        'advanceGold': '10g',
      },
      {
        'name': 'Bob',
        'city': 'Los Angeles',
        'phoneNumber': '234-567-8901',
        'advanceGold': '20g',
      },
    ],
    '2024-10-02': [
      {
        'name': 'Charlie',
        'city': 'Chicago',
        'phoneNumber': '345-678-9012',
        'advanceGold': '30g',
      },
    ],
    '2024-10-03': [], // No items for this date
    '2024-10-04': [
      {
        'name': 'David',
        'city': 'Houston',
        'phoneNumber': '456-789-0123',
        'advanceGold': '40g',
      },
      {
        'name': 'Eva',
        'city': 'Phoenix',
        'phoneNumber': '567-890-1234',
        'advanceGold': '50g',
      },
      {
        'name': 'Frank',
        'city': 'Philadelphia',
        'phoneNumber': '678-901-2345',
        'advanceGold': '60g',
      },
    ],
    // Add more dates and corresponding items as needed
  };

  @override
  void initState() {
    super.initState();
    fetchDates();
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

  // Sample data for dates

  // Method to fetch data from Firestore and update the dates list
  Future<void> fetchDates() async {
    try {
      final snapshot = await fetchAllDocumentSnapshots();
      setState(() {
        dates = snapshot.docs.map((doc) {
          return doc.id; // Assuming `timeStamp` is a timestamp
        }).toList();
        print("dates : $dates");
      });
    } catch (e) {
      print("Error fetching dates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 96, 66, 0),
      appBar: AppBar(
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
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ), // Drawer icon
          onPressed: () {
            // Add your drawer logic here
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.qr_code_scanner_outlined,
              color: Colors.white,
            ), // Scanner icon
            onPressed: () {
              // Add your scanner logic here
            },
          ),
          IconButton(
            icon: Icon(
              isRightPanelOpen ? Icons.arrow_forward : Icons.arrow_back,
              color: Colors.white,
            ), // Toggle icon for opening and closing
            onPressed: () {
              setState(() {
                isRightPanelOpen = !isRightPanelOpen; // Toggle state
              });
            },
          )
        ],
        backgroundColor: Color.fromARGB(255, 96, 66, 0), // Background color
        elevation: 0, // Optional shadow for depth
        centerTitle: true, // Center the title
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0), // Rounded bottom corners
          ),
        ),
      ),
      body: Container(
        child: Row(
          children: [
            // Left side with detailed view (3/4 width)
            Expanded(
              flex: 3,
              child: selectedDate != null
                  ? Container(
                      margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 155, 155, 155), // Gold color
                          width: 2.0, // Adjust the width as needed
                        ),

                        color: Color.fromARGB(246, 2, 17,
                            34), // Background color (set to your preference)
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                          bottom: Radius.circular(
                              30), // Adjust radius for bottom corners
                        ),
                      ),

                      padding: const EdgeInsets.all(0.0),
                      // Background color for the detail view
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 4, 52, 135)
                                  .withOpacity(0.2),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Details for $selectedDate',
                                style: GoogleFonts.spectralSc(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: dateDetails[selectedDate]?.isNotEmpty ==
                                      true
                                  ? ListView.builder(
                                      itemCount:
                                          dateDetails[selectedDate]?.length ??
                                              0,
                                      itemBuilder: (context, index) {
                                        var doc =
                                            dateDetails[selectedDate]![index];
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                15), // Curved border
                                            border: Border.all(
                                              color:
                                                  Colors.white, // Border color
                                              width:
                                                  0, // Slight border width for visibility
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  'https://cdn.vectorstock.com/i/500p/81/36/luxury-black-gold-background-elegant-business-vector-52808136.jpg'), // Background image
                                              fit: BoxFit
                                                  .cover, // Ensure the image covers the entire container
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors
                                                    .black54, // Add some transparency to enhance readability
                                                Colors.black54,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 18.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Barcode placeholder
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[800]
                                                            ?.withOpacity(
                                                                0.8), // Darker, semi-transparent background for the barcode
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      width: 230,
                                                      height: 40,
                                                      child: Center(
                                                        child: Text(
                                                          'Barcode here',
                                                          style: GoogleFonts
                                                              .spectralSc(
                                                            textStyle:
                                                                TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .white, // Changed to white for contrast
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),

                                                    // Information rows
                                                    _buildInfoRow(
                                                        "Customer Name :",
                                                        doc['name']),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                        "City                         :",
                                                        doc['city']),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                        "Phone Number   :",
                                                        doc['phoneNumber']),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                        "Advance Gold    :",
                                                        doc['advanceGold']),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        // WhatsApp logic
                                                      },
                                                      icon: Icon(
                                                        FontAwesomeIcons
                                                            .whatsapp,
                                                        color: Colors
                                                            .greenAccent[400],
                                                        size:
                                                            40, // Slightly larger icon for better visibility
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                'Print',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Lato',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              content:
                                                                  const Text(
                                                                'Printing functionality goes here.',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Lato'),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Close',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Lato',
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
                                                      icon: Icon(
                                                        FontAwesomeIcons.print,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 0, 11, 39),
                                                        size:
                                                            40, // Slightly larger icon for better visibility
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        'No data available for this date.',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'Select a date to view details',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),

            // Right side with dates (1/4 width)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isRightPanelOpen
                  ? MediaQuery.of(context).size.width * 0.23
                  : 0, // Width is 0 when closed
              color: Color.fromARGB(
                  255, 96, 66, 0), // Background color for the date list
              child: isRightPanelOpen
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Logic to open date picker or perform the desired action
                            },
                            //right side dates
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 20.0),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 209, 207,
                                    207), // Background color for the input-like appearance
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        0.15), // Subtle shadow effect
                                    blurRadius: 2.0,
                                    spreadRadius: 2.0,
                                    offset: const Offset(
                                        0, 4), // Slightly raised shadow effect
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey
                                      .shade300, // Light border color for the input effect
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Select a Date',
                                    style: GoogleFonts.spectralSc(
                                      textStyle: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors
                                            .black87, // Dark color for input text
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.grey.shade600, // Icon color
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: const Color.fromARGB(
                                255, 96, 66, 0), // Darker Gold
                            height: MediaQuery.of(context).size.height - 100,
                            child: FutureBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              future: fetchAllDocumentSnapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: const LoadingIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Text('No documents found'),
                                  );
                                } else {
                                  return ListView.builder(
                                    itemCount: dates.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDate = dates[index];
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 10.0),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 16),
                                          decoration: BoxDecoration(
                                            gradient: selectedDate ==
                                                    dates[index]
                                                ? LinearGradient(
                                                    colors: [
                                                      const Color.fromARGB(
                                                          255, 9, 24, 84),
                                                      const Color.fromARGB(
                                                          255, 11, 32, 54)
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      Colors.grey.shade800,
                                                      Colors.black87
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    selectedDate == dates[index]
                                                        ? Colors.orangeAccent
                                                            .withOpacity(0.5)
                                                        : Colors.black54,
                                                blurRadius: 0.0,
                                                spreadRadius: 0.0,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                            border: Border.all(
                                              color:
                                                  selectedDate == dates[index]
                                                      ? const Color.fromARGB(
                                                          255, 184, 182, 182)
                                                      : Colors.transparent,
                                              width: 1.5, // Adjusted width
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              dates[index], //list of dates
                                              style: GoogleFonts.mate(
                                                fontSize:
                                                    18, // Increased font size
                                                fontWeight: FontWeight
                                                    .w600, // Bolder font weight
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(), // Empty container when closed
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Consistent Styling of Info Rows
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
