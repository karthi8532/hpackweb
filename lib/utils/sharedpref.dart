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

  static Future<bool> setApproverUserId(String value) async =>
      await _prefs.setString('ApprovedUserID', value);

  static Future<bool> setIsSupervisor(String value) async =>
      await _prefs.setString('IsSupervisor', value);

  static Future<bool> setFromMailID(String value) async =>
      await _prefs.setString('FromMail', value);

  static Future<bool> setToMailID(String value) async =>
      await _prefs.setString('ToMail', value);

  // ===== Getters =====
  static bool? getLoggedIn() => _prefs.getBool('isLoggedIn');

  static String? getEmpID() => _prefs.getString('Id');

  static String? getName() => _prefs.getString('Name');

  static String? getApprovedByUserId() => _prefs.getString('ApprovedUserID');
  static String? getIsSupervisor() => _prefs.getString('IsSupervisor');
  static String? getFromMailID() => _prefs.getString('FromMail');
  static String? getToMailID() => _prefs.getString('ToMail');

  // ===== Clear/Delete =====
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();
}
