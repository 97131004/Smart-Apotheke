import 'dart:async';
import 'package:steel_crypt/steel_crypt.dart';
import '../util/helper.dart';

class PersonalData {
  static final String saveKeyPassword = 'password';
  static final String saveKeyIban = 'iban';
  static final String saveKeyAddress = 'address';
  static var hasher = HashCrypt('SHA-3/512');

  static Future<bool> isUserDataComplete() async {
    final addr = await Helper.readDataFromsp(saveKeyAddress);
    final iban = await Helper.readDataFromsp(saveKeyIban);
    return addr != '' && iban != '';
  }

  static Future<bool> passwordExists() async {
    final value = await Helper.readDataFromsp(saveKeyPassword);
    //print('read: $value');
    if (value != '') return true;
    return false;
  }

  static Future setPassword(String password) async {
    String hash = hasher.hash(password);
    Helper.writeDatatoSp(saveKeyPassword, hash);
  }

  static Future<bool> checkPassword(String password) async {
    final value = await Helper.readDataFromsp(saveKeyPassword);
    if (value != '') return hasher.checkhash(password, value);
    return false;
  }

  static Future<bool> resetPassword(String oldp, String newp) async {
    if (await checkPassword(oldp)) {
      await setPassword(newp);
      return true;
    }
    return false;
  }

  static Future<bool> changeIban(String iban, String password) async {
    if (await checkPassword(password)) {
      iban = await encrypt(iban);
      Helper.writeDatatoSp(saveKeyIban, iban);
      return true;
    }
    return false;
  }

  static Future<bool> changeAddress(
      List<String> adresse, String password) async {
    if (await checkPassword(password)) {
      String _adresse = adresse.join('?').toString();
      _adresse = await encrypt(_adresse);
      Helper.writeDatatoSp(saveKeyAddress, _adresse);
      return true;
    }
    return false;
  }

  static Future<String> getIban() async {
    String ibanencrypted = await Helper.readDataFromsp(saveKeyIban);
    if (ibanencrypted.isNotEmpty)
      return decrypt(ibanencrypted);
    else
      return '';
  }

  static Future<List<String>> getAddress() async {
    String adresseencrypted = await Helper.readDataFromsp(saveKeyAddress);
    if (adresseencrypted.isNotEmpty)
      return (await decrypt(adresseencrypted)).split('?');
    return null;
  }

  static Future<String> encrypt(String text) async {
    var fortunaKey = CryptKey().genFortuna();
    var iv2 = CryptKey().genDart(12);
    var encrypter3 = AesCrypt(fortunaKey, 'cbc', 'iso10126-2');
    String en = encrypter3.encrypt(text, iv2);
    return fortunaKey + ' ' + iv2 + ' ' + en;
  }

  static Future<String> decrypt(String encrypted) async {
    List<String> enc = encrypted.split(' ');
    String fortunaKey = enc[0];
    String iv2 = enc[1];
    encrypted = enc[2];
    var encrypter3 = AesCrypt(fortunaKey, 'cbc', 'iso10126-2');
    return encrypter3.decrypt(encrypted, iv2);
  }
}
