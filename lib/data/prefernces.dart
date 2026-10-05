import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _prefs;

  static const String authCode = 'authCode';
  static const String userID = 'userID'; 
  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String aadhar = 'aadhar';
  static const String location = 'location';
  static const String distance = 'distance';
  static const String status = 'status';
  static const String roleID = 'roleID';
  static const String refLink = 'refLink';
  static const String userDetails = 'user';
  static const String profilePic = 'profilePic';

  /// Initialize shared preferences
  static Future<void> initSharedPreference() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure _prefs is initialized before use
  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Clear all preferences
  static Future<void> clearPreference() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  /// User Details
  static Future<void> setUserDetails(String user) async {
    final prefs = await _getPrefs();
    await prefs.setString(userDetails, user);
  }

  static Future<String?> getUserDetails() async {
    final prefs = await _getPrefs();
    return prefs.getString(userDetails);
  }

  /// Auth Code
  static Future<void> setAuthCode(String authCodeNew) async {
    final prefs = await _getPrefs();
    await prefs.setString(authCode, authCodeNew);
  }

  static Future<String?> getAuthCode() async {
    final prefs = await _getPrefs();
    return prefs.getString(authCode);
  }

  /// User ID
  static Future<void> setUserID(String userIDNew) async {
    final prefs = await _getPrefs();
    await prefs.setString(userID, userIDNew);
  }

  static Future<String?> getUserID() async {
    final prefs = await _getPrefs();
    return prefs.getString(userID);
  }

  /// Name
  static Future<void> setName(String nameNew) async {
    final prefs = await _getPrefs();
    await prefs.setString(name, nameNew);
  }

  static Future<String?> getName() async {
    final prefs = await _getPrefs();
    return prefs.getString(name);
  }

  static String? getNameSync() {
    return _prefs?.getString(name);
  }

  /// Email
  static Future<void> setEmail(String emailNew) async {
    final prefs = await _getPrefs();
    await prefs.setString(email, emailNew);
  }

  static Future<String?> getEmail() async {
    final prefs = await _getPrefs();
    return prefs.getString(email);
  }

  /// Phone
  static Future<void> setPhone(String phoneNew) async {
    final prefs = await _getPrefs();
    await prefs.setString(phone, phoneNew);
  }

  static Future<String?> getPhone() async {
    final prefs = await _getPrefs();
    return prefs.getString(phone);
  }

  static String? getPhoneSync() {
    return _prefs?.getString(phone);
  }

  /// Profile Picture
  static Future<void> setProfilePic(String profileUrl) async {
    final prefs = await _getPrefs();
    await prefs.setString(profilePic, profileUrl);
  }

  static Future<String?> getProfilePic() async {
    final prefs = await _getPrefs();
    return prefs.getString(profilePic);
  }

  static String? getProfilePicSync() {
    return _prefs?.getString(profilePic);
  }

  /// Aadhar
  static Future<void> setAadhar(String aadharNew) async {
    final prefs = await _getPrefs();
    await prefs.setString(aadhar, aadharNew);
  }

  static Future<String?> getAadhar() async {
    final prefs = await _getPrefs();
    return prefs.getString(aadhar);
  }

  /// Location
  static Future<void> setLocation(String locationNew) async {
    final prefs = await _getPrefs();
    await prefs.setString(location, locationNew);
  }

  static Future<String?> getLocation() async {
    final prefs = await _getPrefs();
    return prefs.getString(location);
  }

  ///
}