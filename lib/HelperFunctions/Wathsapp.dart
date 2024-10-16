import 'package:leelacasting/CommonWidgets/Loading.dart';
import 'package:leelacasting/HelperFunctions/PhoneNumberFormat.dart';
import 'package:url_launcher/url_launcher.dart';

class Wathsapp {
  // Replace with your business phone number
  static final String baseWhatsAppLink = 'https://wa.me/';


  static Future<String> createWhatsAppLink(String phoneNumber, String userName) async{
    String phoneNumber_ = await PhoneNumberFormat.formatPhoneNumber(phoneNumber);
    String message =
        'Hi%2C%$userName';
    return '$baseWhatsAppLink$phoneNumber_?text=$message';
  }

  // Launches WhatsApp with the constructed URL
  static Future<void> launchWhatsApp(String url) async {
    // Checking if the constructed URL can be launched
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Method to send a message to the customer based on phone number
  static Future<void> sendMessageToCustomerFromWhatsApp(String phoneNumber, String userName) async {
    String whatsappLink = await createWhatsAppLink(phoneNumber, userName);
    try {
      await launchWhatsApp(whatsappLink);
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }
}
