import 'dart:io';

import 'package:steel_crypt/steel_crypt.dart';
import '../util/helper.dart';

class Password {
  static File file;
  static String filename =
      'db.txt'; //file, where the hash code for encoding / dycription password is stored
  static var hasher = HashCrypt("SHA-3/512");
  static Future<bool> isPasswordExists() async {
    String hash = await Helper.readData(filename);
    print(hash);
    if (hash.isEmpty || hash == '')
      return false;
    else
      return true;
  }

  static Future<bool> setpassword(String password) async {
    try {
      String hash = hasher.hash(password);
      await Helper.writeData(filename, hash);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<bool> checkPassword(String password) async {
    String hash = await Helper.readData(filename);
    return hasher.checkhash(password, hash);
  }

  static Future<bool> resetPassword(String oldp, String newp) async {
    if (await checkPassword(oldp) != null) {
      if (await setpassword(newp)) {
        print('reset password done!');
        return true;
      } else
        print('reset password failed!');
        return false;
    } else {
      return false;
    }
  }
}
