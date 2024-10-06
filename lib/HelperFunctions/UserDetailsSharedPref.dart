import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsSharedPref {
  static const String _userPhoneNumberKey = 'userPhoneNumber';
  static const String _userNameKey = 'userName';
  static const String _AdminKey = 'Admin';
  static const String _superAdminkey = 'superAdmin';

  static String? userPhoneNumber;
  static String? userName;
  static String? Admin;
  static String? superAdmin;

  static bool isAdmin = false;
  static bool issuperAdmin = false;
  // static const String _userEmailKey = 'userEmail';
  // static const String _userCityKey = 'userCity';

  // // Save user details
  // static Future<void> saveUserDetails({
  //   required String userPhoneNumber,
  //   required String userName,
  //   // required String userEmail,
  //   // required String userCity,
  // }) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_userPhoneNumberKey, userPhoneNumber);
  //   await prefs.setString(_userNameKey, userName);
  //   // await prefs.setString(_userEmailKey, userEmail);
  //   // await prefs.setString(_userCityKey, userCity);
  // }

  // Retrieve user details
  static Future<Map<String, String?>> getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userPhoneNumber = prefs.getString(_userPhoneNumberKey);
    userName = prefs.getString(_userNameKey);
    Admin = prefs.getString(_AdminKey);
    superAdmin = prefs.getString(_superAdminkey);
    userName = prefs.getString(_userNameKey);

    // String? userEmail = prefs.getString(_userEmailKey);
    // String? userCity = prefs.getString(_userCityKey);

    if (Admin == 'Admin') {
      isAdmin = true;
    }
    if (superAdmin == 'superAdmin') {
      issuperAdmin = true;
    }

    return {
      'userPhoneNumber': userPhoneNumber,
      'userName': userName,
      'Admin': Admin,
      'superAdmin': superAdmin,
      'isAdmin': isAdmin.toString(),
      'isSuperAdmin': issuperAdmin.toString(),
      // 'userEmail': userEmail,
      // 'userCity': userCity,
    };
  }
}