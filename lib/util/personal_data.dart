import 'dart:async';
import 'package:steel_crypt/steel_crypt.dart';
import '../util/helper.dart';

/// Helper class to manage personal data, including encryption, decryption, hashing, loading 
/// and saving of passwords, name, address and iban. The password is saved as a hash to the
/// android's shared preferences (local settings storage). The name, adress and iban are 
/// encrypted on write and decrypted on read from android's shared preferences.

class PersonalData {
  /// Save key for password's load and save functions.
  static final String _saveKeyPassword = 'password';

  /// Save key for iban's load and save functions.
  static final String _saveKeyIban = 'iban';

  /// Save key for address' load and save functions.
  static final String _saveKeyAddress = 'address';

  /// Initializing hasher with a hashing type. Used for password checks.
  static var _hasher = HashCrypt('SHA-3/512');

  /// Returns whether user data is complete.
  static Future<bool> isUserDataComplete() async {
    final addr = await Helper.readDataFromsp(_saveKeyAddress);
    final iban = await Helper.readDataFromsp(_saveKeyIban);
    return addr != '' && iban != '';
  }

  /// Returns whether a password has been already set.
  static Future<bool> passwordExists() async {
    final value = await Helper.readDataFromsp(_saveKeyPassword);
    if (value != '') return true;
    return false;
  }

  /// Sets a new password and saves it.
  static Future setPassword(String password) async {
    String hash = _hasher.hash(password);
    Helper.writeDatatoSp(_saveKeyPassword, hash);
  }

  /// Checks whether a password is valid.
  static Future<bool> checkPassword(String password) async {
    final value = await Helper.readDataFromsp(_saveKeyPassword);
    if (value != '') return _hasher.checkhash(password, value);
    return false;
  }

  /// Changes a password from [oldPass] to [newPass] and saves it.
  static Future<bool> resetPassword(String oldPass, String newPass) async {
    if (await checkPassword(oldPass)) {
      await setPassword(newPass);
      return true;
    }
    return false;
  }

  /// Changes the iban and saves it. Requires the current password.
  static Future<bool> changeIban(String iban, String password) async {
    if (await checkPassword(password)) {
      iban = await encrypt(iban);
      Helper.writeDatatoSp(_saveKeyIban, iban);
      return true;
    }
    return false;
  }

  /// Changes the address and saves it.
  static Future<bool> changeAddress(
      List<String> address, String password) async {
    if (await checkPassword(password)) {
      String addr = address.join('?').toString();
      addr = await encrypt(addr);
      Helper.writeDatatoSp(_saveKeyAddress, addr);
      return true;
    }
    return false;
  }

  /// Returns the current iban.
  static Future<String> getIban() async {
    String ibanEncrypted = await Helper.readDataFromsp(_saveKeyIban);
    if (ibanEncrypted.isNotEmpty)
      return decrypt(ibanEncrypted);
    else
      return '';
  }

  /// Returns the current address.
  static Future<List<String>> getAddress() async {
    String addressEncrypted = await Helper.readDataFromsp(_saveKeyAddress);
    if (addressEncrypted.isNotEmpty)
      return (await decrypt(addressEncrypted)).split('?');
    return null;
  }

  /// Encrypts a string with the symmetric AES algorithm.
  static Future<String> encrypt(String text) async {
    String fortunaKey = CryptKey().genFortuna();
    String iv = CryptKey().genDart(12);
    var encrypter = AesCrypt(fortunaKey, 'cbc', 'iso10126-2');
    String en = encrypter.encrypt(text, iv);
    return fortunaKey + ' ' + iv + ' ' + en;
  }

  /// Decrypts a string with the symmetric AES algorithm.
  static Future<String> decrypt(String encrypted) async {
    List<String> enc = encrypted.split(' ');
    String fortunaKey = enc[0];
    String iv = enc[1];
    encrypted = enc[2];
    var encrypter = AesCrypt(fortunaKey, 'cbc', 'iso10126-2');
    return encrypter.decrypt(encrypted, iv);
  }
}
