import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:connectivity/connectivity.dart';

class Helper {
  static String parseMid(String source, String delim1, String delim2,
      [int startIndex]) {
    int iDelim1 = source.indexOf(delim1, (startIndex != null) ? startIndex : 0);
    int iDelim2 = source.indexOf(delim2, iDelim1 + delim1.length);
    if (iDelim1 != -1 && iDelim2 != -1) {
      return source.substring(iDelim1 + delim1.length, iDelim2);
    }
    return '';
  }

  static bool isNumber(String pzn) {
    //dont use isNumeric(), it accepts - and + signs
    for (int i = 0; i < pzn.length; i++) {
      if (!(pzn[i].codeUnitAt(0) >= 48 && pzn[i].codeUnitAt(0) <= 57)) {
        return false;
      }
    }
    return true;
  }

  static Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<File> localFile(String filename) async {
    final path = await localPath;
    return new File('$path/$filename');
  }

  static Future<String> readDatafromFile(String filename) async {
    try {
      final file = await localFile(filename);
      String body = await file.readAsString();
      return body;
    } catch (e) {
      await writeDatafromFile(filename, '');
      print('The file $filename dont exists. Creating a new one....');
      return '';
    }
  }

  static Future<File> writeDatafromFile(String filename, String data) async {
    final file = await localFile(filename);
    return file.writeAsString('$data');
  }

  static Future<String> readDataFromsp(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? '';
    print('read: $value');
    return value;
  }

  static Future writeDatatoSp(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    final value = data;
    prefs.setString(key, value);
    print('saved $value');
  }

  static Future<bool> hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
