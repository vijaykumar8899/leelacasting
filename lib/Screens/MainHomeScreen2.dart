import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MainHomeScreen2 extends StatefulWidget {
  const MainHomeScreen2({super.key});

  @override
  _MainHomeScreen2State createState() => _MainHomeScreen2State();
}

class _MainHomeScreen2State extends State<MainHomeScreen2> {
  bool isCalculateToMoneyOn = false;
  bool isTransactionClosedOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 96, 66, 0),
      appBar: AppBar(
        title: Text(
          'Caluclate Page',
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildDetailedContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 4, 52, 135).withOpacity(0.2),
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
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
                                color: Colors.grey[800]?.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              width: 230,
                              height: 40,
                              child: Center(
                                child: Text(
                                  'Barcode here',
                                  style: GoogleFonts.spectralSc(
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow("Customer Name       : ", 'name'),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                                "City                               : ",
                                'city'),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                                "Phone Number          : ", 'phoneNumber'),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                                "Advance Gold           : ", 'advanceGold'),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                                "Type                               : ",
                                'Molding, Casting 100%'),
                            const SizedBox(height: 8),
                            _buildInfoRow("Ornament Weight  : ", '3'),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                                "Gold Rate                   : ", '7800'),
                            const SizedBox(height: 8),
                            _buildInfoRow("Pending Gold            : ", '1.0'),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                // WhatsApp logic
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
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Print',
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        'Printing functionality goes here.',
                                        style: GoogleFonts.lato(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Close',
                                            style: GoogleFonts.lato(
                                              color: Colors.blueAccent,
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
                                color: Color.fromARGB(255, 0, 11, 39),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "   3000 × 100%",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(221, 207, 207, 207),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "=  3.000 - 2.0",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(221, 207, 207, 207),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "=      1.000",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 50),
          Center(
            child: Container(
              height: 60, // Height for a more button-like feel
              width: 250, // Fixed width
              child: Material(
                elevation: 10, // Elevation for depth
                borderRadius: BorderRadius.circular(10), // Rounded corners
                child: ElevatedButton(
                  onPressed: () {
                    // Action when the button is clicked
                    print("Button clicked!");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 32, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded shape
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15), // Padding
                    shadowColor: Colors.black.withOpacity(0.5), // Shadow depth
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
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  toggleValue: isCalculateToMoneyOn,
                  onToggleChanged: (value) {
                    setState(() {
                      isCalculateToMoneyOn = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey.shade700, thickness: 1),
                SizedBox(height: 10),
                _buildRowItem(
                  label: "Transaction Closed",
                  toggleValue: isTransactionClosedOn,
                  onToggleChanged: (value) {
                    setState(() {
                      isTransactionClosedOn = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Container(
              height: 80, // Increased height for a more button-like feel
              width: 950, // Fixed width to make it more button-like
              child: Material(
                elevation: 30, // Added elevation for a pronounced effect
                borderRadius: BorderRadius.circular(10), // Rounded corners
                child: ElevatedButton(
                  onPressed: () {
                    // Define what happens when the button is clicked.
                    print("Button clicked!");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 29, 53),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15), // Increased padding
                    shadowColor: Colors.black
                        .withOpacity(0.5), // Shadow color for more depth
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
    );
  }

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
