import 'dart:async';

import 'package:steel_crypt/steel_crypt.dart';
import '../util/helper.dart';

class PersonalData {
  static String keyPassword = 'password';
  static String keyIban = 'iban';
  static String keyadresse = 'adresse';
  static var hasher = HashCrypt("SHA-3/512");

  static bool isUserDataComplete() {
    return keyPassword != 'passwiord' && keyIban != 'iban' && keyadresse != 'adresse';
  }

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
    if (value != '') return hasher.checkhash(password, value);
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
      iban = await encrypt(iban);
      Helper.writeDatatoSp(keyIban, iban);
      return true;
    }
    return false;
  }

  static Future<bool> changeadresse(
      List<String> adresse, String password) async {
    if (await checkPassword(password)) {
      String _adresse = adresse.join('?').toString();
      _adresse = await encrypt(_adresse);
      Helper.writeDatatoSp(keyadresse, _adresse);
      return true;
    }
    return false;
  }

  static Future<String> getIban() async {
    String ibanencrypted = await Helper.readDataFromsp(keyIban);
    if (ibanencrypted.isNotEmpty)
      return decrypt(ibanencrypted);
    else
      return '';
  }

  static Future<List<String>> getadresse() async {
    String adresseencrypted = await Helper.readDataFromsp(keyadresse);
    if (adresseencrypted.isNotEmpty)
      return (await decrypt(adresseencrypted)).split('?');
    return null;
  }

  static Future<String> encrypt(String text) async {
    var FortunaKey  = CryptKey().genFortuna();
    var iv2 = CryptKey().genDart(12);
    var encrypter3 = AesCrypt(FortunaKey , 'cbc', 'iso10126-2');
    String en = encrypter3.encrypt(text, iv2);
    return FortunaKey + " " + iv2 + " " + en;
  }

  static Future<String> decrypt(String encrypted) async {
    List<String> enc = encrypted.split(" ");
    String FortunaKey = enc[0];
    String iv2 = enc[1];
    encrypted = enc[2];
    var encrypter3 = AesCrypt(FortunaKey , 'cbc', 'iso10126-2');
    return encrypter3.decrypt(encrypted, iv2);
  }
}
