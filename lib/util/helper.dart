import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/med.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import '../data/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

/// Helper class with globally accessible functions.

class Helper {
  /// Save key for [globals.recentMeds] list's load and save functions.
  static final String saveKeyGlobalsList = 'globalsList';

  /// Parses middle string from input string [source] between [delim1] and [delim2].
  static String parseMid(String source, String delim1, String delim2,
      [int startIndex]) {
    if (source.length <= 0 ||
        (startIndex != null && startIndex > source.length - 1)) return '';
    int iDelim1 = source.indexOf(delim1, (startIndex != null) ? startIndex : 0);
    int iDelim2 = source.indexOf(delim2, iDelim1 + delim1.length);
    if (iDelim1 != -1 && iDelim2 != -1) {
      return source.substring(iDelim1 + delim1.length, iDelim2);
    }
    return '';
  }

  /// Checks whether input string [s] is a pure integer (only includes numbers 0 to 9).
  static bool isPureInteger(String s) {
    /// Filtering for numbers 0 to 9, leaving out + and - signs.
    for (int i = 0; i < s.length; i++) {
      if (!(s[i].codeUnitAt(0) >= 48 && s[i].codeUnitAt(0) <= 57)) {
        return false;
      }
    }
    return true;
  }

  /// Retrieves local path to application documents directory.
  static Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Retrieves local file in local application documents directory.
  static Future<File> getLocalFile(String filename) async {
    final path = await localPath;
    return new File('$path/$filename');
  }

  /// Reads data from local file.
  static Future<String> readDataFromFile(String filename) async {
    try {
      final file = await getLocalFile(filename);
      String body = await file.readAsString();
      print(body);
      return body;
    } catch (e) {
      await writeDataToFile(filename, '');
      print('The file $filename dont exists. Creating a new one....');
      return '';
    }
  }

  /// Writes data to local file.
  static Future<File> writeDataToFile(String filename, String data) async {
    final file = await getLocalFile(filename);
    return file.writeAsString('$data');
  }

  /// Reads data from android's shared preferences (local settings storage).
  static Future<String> readDataFromsp(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? '';
    print('read: $value');
    return value;
  }

  /// Writes data to android's shared preferences (local settings storage).
  static Future writeDatatoSp(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final value = data;
    prefs.setString(key, value);
    print('saved $value');
  }

  /// Checks whether there is a working internet connection.
  static Future<bool> hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  /// Fetches html from an [url] and returns its response data on success, or null on failure.
  static Future<String> fetchHTML(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200)
      return response.body;
    else
      return null;
  }

  /// Adds a new medicament [med] to the [globals.recentMeds] list as the latest entry.
  /// Removes duplicates.
  static void recentMedsAdd(Med m) {
    globals.recentMeds.removeWhere((item) => item.pzn == m.pzn);
    m.isHistory = true;
    globals.recentMeds.add(m);
  }

  /// Saves [globals.recentMeds] list to android's shared preferences.
  static Future recentMedsSave() async {
    List<String> list = [];
    for (int i = 0; i < globals.recentMeds.length; i++) {
      /// Encoding each [med] object to a json string representation.
      list.add(jsonEncode(globals.recentMeds[i].toJson()));
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    /// Saving [List<Med>] as a [List<String>], where each medicament is a json string.
    await prefs.setStringList(saveKeyGlobalsList, list);
  }

  /// Loads [globals.recentMeds] list from android's shared preferences.
  static Future recentMedsLoad() async {
    // Enable next line to not add predefined med's from the globals.recentMeds list.
    // globals.recentMeds.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list =
        (prefs.getStringList(saveKeyGlobalsList) ?? List<String>());
    for (int i = 0; i < list.length; i++) {
      /// Decoding each json string to a [med] object.
      Med m = Med.fromJson(jsonDecode(list[i]));
      recentMedsAdd(m);
    }
  }

  /// Displays a common toast message at the bottom of the screen.
  static void showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      timeInSecForIos: 1,
      fontSize: 15,
    );
  }
}
