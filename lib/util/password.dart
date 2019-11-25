import 'dart:async';
import 'dart:io';

import 'package:steel_crypt/steel_crypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/helper.dart';

class PersonalData {
  static String keyPassword = 'password';
  static String keyIban = 'iban';
  static String keyName = 'name';
  static String keyfName = 'vorname';
  static String keyAdresse = 'adresse';
  static String keypostcode = 'plz';
  static String keycity = 'stadt';
  static var hasher = HashCrypt("SHA-3/512");

  static Future<bool> isPasswordExists() async {
   final value = await Helper.readDataFromsp(keyPassword);
    //print('read: $value');
    if (value != '') return true;
    return false;
  }

  static Future setpassword(String password) async {
      String hash = hasher.hash(password);
      Helper.writeDatatoSp(keyPassword, hash);
  }

  static Future<bool> checkPassword(String password) async {
    final value = await Helper.readDataFromsp(keyPassword);
    if (value != '')return hasher.checkhash(password, value);
    return false;
  }

  static Future<bool> resetPassword(String oldp, String newp) async {
    if (await checkPassword(oldp)) {
        await setpassword(newp);
        return true;
    }
    return false;
  }
  
  static Future<bool> changeIban(String iban, String password) async {
    if (await checkPassword(password)) {
      Helper.writeDatatoSp(keyIban, iban);
      return true;
    }
    return false;
  }
}
