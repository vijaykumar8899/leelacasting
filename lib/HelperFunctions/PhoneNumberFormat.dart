class PhoneNumberFormat{
 static Future<String> formatPhoneNumber(String phoneNumber) async{
    // Remove any non-numeric characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (!phoneNumber.startsWith('91')) {
      phoneNumber = '91$phoneNumber';
    }

    if (phoneNumber.length == 10 && phoneNumber.startsWith('91')) {
      phoneNumber = '91$phoneNumber';
    }

    // Check if the number starts with a leading plus (+)
    if (!phoneNumber.startsWith('+')) {
      // Add the leading plus for international format
      phoneNumber = '+$phoneNumber';
    }
    print('phoneNumber : $phoneNumber');
    return phoneNumber;
  }
}