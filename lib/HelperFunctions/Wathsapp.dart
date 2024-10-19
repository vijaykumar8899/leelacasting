import 'package:leelacasting/CommonWidgets/Loading.dart';
import 'package:leelacasting/HelperFunctions/PhoneNumberFormat.dart';
import 'package:url_launcher/url_launcher.dart';

class Wathsapp {
  static final String baseWhatsAppLink = 'https://wa.me/';

  static Future<String> createWhatsAppLink(String phoneNumber, String userName) async {
    print("createWhatsAppLink");
    String phoneNumber_ = await PhoneNumberFormat.formatPhoneNumber(phoneNumber);
    print("Formatted phoneNumber: $phoneNumber_");  // Log formatted phone number
    String message = 'Hi';
    return '$baseWhatsAppLink$phoneNumber_?text=$message';
  }

  static Future<void> launchWhatsApp(String url) async {
   try{
     final whatsappLink = url;
     launch(whatsappLink);
   }
   catch(e) {
     throw 'Could not launch $url';
   }
  }

  static Future<void> sendMessageToCustomerFromWhatsApp(String phoneNumber, String userName) async {
    print("sendMessageToCustomerFromWhatsApp");
    String whatsappLink = await createWhatsAppLink(phoneNumber, userName);
    try {
      await launchWhatsApp(whatsappLink);
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }
}
