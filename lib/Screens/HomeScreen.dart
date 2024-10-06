import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  Map<String, dynamic>? AllDates;

  @override
  void initState() {
    super.initState();
    fetchDates();
  }

  Future<void> fetchDates() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('leelaCasting')
          .doc('DialyTransactions')
          .get();

      // Check if the document exists
      if (snapshot.exists) {
        AllDates = snapshot.data();
        print('Data fetched: $AllDates');
        // Update state with the fetched data
        setState(() {
          // Store your data to use it in the UI (e.g., assigning to a variable)
          // For example: _fetchedData = data;
        });
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
        ],
      ),
      
    );
  }
}
