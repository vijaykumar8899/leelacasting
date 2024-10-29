import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leelacasting/Screens/HomeScreen.dart';
import 'package:leelacasting/Screens/MainHomeScreen.dart';
import 'package:leelacasting/Screens/MainHomeScreen2.dart';
import 'package:leelacasting/Screens/PayablesScreen.dart';
import 'package:leelacasting/Screens/RecordScreen.dart';
import 'package:leelacasting/Utilites/Colors.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    RecordsScreen(),
    MainHomeScreen(),
    // PayablesScreen(),
    MainHomeScreen2(),
  ];

  changeIndex(int selectedIndex) {
    setState(() {
      _currentIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 96, 66, 0), // Darker background for contrast
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E21), // Darker nav background
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: changeIndex,
            selectedItemColor: AppColors.primaryClr,
            unselectedItemColor: const Color.fromARGB(255, 15, 15, 15),
            showUnselectedLabels: false,
            selectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            items: [
              BottomNavigationBarItem(
                icon: _buildTabIcon(FontAwesomeIcons.clipboardList,
                    isActive: _currentIndex == 0),
                label: "Records",
              ),
              BottomNavigationBarItem(
                icon: _buildTabIcon(FontAwesomeIcons.home,
                    isActive: _currentIndex == 1),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: _buildTabIcon(FontAwesomeIcons.wallet,
                    isActive: _currentIndex == 2),
                label: "Payables",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build a customized tab icon with animations and ripple effect
  Widget _buildTabIcon(IconData iconData, {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryClr.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(
        iconData,
        size: isActive
            ? 28
            : 26, // Highlight active icon with a subtle size difference
        color: isActive ? AppColors.primaryClr : Colors.grey[500],
      ),
    );
  }
}
