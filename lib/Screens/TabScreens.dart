import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leelacasting/Screens/HomeScreen.dart';
import 'package:leelacasting/Screens/PayablesScreen.dart';
import 'package:leelacasting/Screens/ReceivablesScreen.dart';
import 'package:leelacasting/Screens/RecordScreen.dart';
import 'package:leelacasting/Utilites/Colors.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabsScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    RecordsScreen(),
    const ReceivablesScreen(),
    const PayablesScreen()
  ];

  changeIndex(selectedIndex) {
    setState(() {
      _currentIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: changeIndex,
          selectedItemColor: AppColors.primaryClr,
          unselectedItemColor: Colors.black,
          items: const [
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.newspaper),
              label: "Home",
            ),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.fileInvoiceDollar),
                label: "Recivables"),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.moneyBillWave), label: "Payables"),
            // BottomNavigationBarItem(
            // icon: Icon(FontAwesomeIcons.user), label: "Profile"),
          ]),
    );
  }
}
