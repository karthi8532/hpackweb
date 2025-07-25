import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== Setters =====
  static Future<bool> setLoggedIn(bool value) async =>
      await _prefs.setBool('isLoggedIn', value);

  static Future<bool> setEmpID(String value) async =>
      await _prefs.setString('Id', value);

  static Future<bool> setName(String value) async =>
      await _prefs.setString('Name', value);

    static Future<bool> setApprovedBy(String value) async =>
      await _prefs.setString('ApprovedBy', value);

  static Future<bool> setApproverUserId(String value) async =>
      await _prefs.setString('ApprovedUserID', value);    

  // ===== Getters =====
  static bool? getLoggedIn() => _prefs.getBool('isLoggedIn');

  static String? getEmpID() => _prefs.getString('Id');

  static String? getName() => _prefs.getString('Name');

  static String? getApprovedBy() => _prefs.getString('ApprovedBy');
  static String? getApprovedByUserId() => _prefs.getString('ApprovedUserID');

  // ===== Clear/Delete =====
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();
}
