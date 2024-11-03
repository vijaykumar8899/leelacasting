import 'package:flutter/material.dart';
import 'package:leelacasting/Screens/TabScreens.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerScreen extends StatefulWidget {
  const PermissionHandlerScreen({super.key});

  @override
  State<PermissionHandlerScreen> createState() => _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    // Request camera permission
    var cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
      print('Camera permission granted');
    } else {
      print('Camera permission denied');
    }

    // Request storage permission
    var storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }

    // Request Bluetooth permission
    var bluetoothStatus = await Permission.bluetooth.request();
    if (bluetoothStatus.isGranted) {
      print('Bluetooth permission granted');
    } else {
      print('Bluetooth permission denied');
    }

    // If all permissions are granted, navigate to TabsScreen
    if (cameraStatus.isGranted && storageStatus.isGranted && bluetoothStatus.isGranted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TabsScreen()),
      );
    } else {
      print('Not all permissions granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Handler Example'),
      ),
      body: Center(
        child: Text('Requesting permissions...'),
      ),
    );
  }
}
