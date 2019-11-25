import 'package:path_provider/path_provider.dart';
import 'dart:io';

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

  static Future<File> localFile(String filename)async {
    final path = await localPath;
    return new File('$path/$filename');
  }

  static Future<String> readData(String filename) async {
    try {
      final file = await localFile(filename);
      String body = await file.readAsString();
      return body;
    } catch (e) {
      await writeData(filename,'');
      print( 'The file $filename dont exists. Creating a new one....');
      return '';
    }
  }

  static Future<File> writeData(String filename, String data) async {
    final file = await localFile(filename);
    return file.writeAsString('$data');
  }
}
