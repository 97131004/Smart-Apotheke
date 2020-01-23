import 'package:maph_group3/util/personal_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests  functions in the file personal data
/// We have to setup shared Preferences in yarm

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group("Personal Data Tets", (){
    group('[Testing Password]', () {
      test('Set a new password for the user', () async {
        String password = await  PersonalData.setPassword("123");
        bool checkPassword = await PersonalData.checkPassword("123");
        expect(checkPassword, true);
      });

      test('Reset Passord', () async{
        bool checkResetPass = await PersonalData.resetPassword("123", "234");
        expect(checkResetPass, true);
      });
    });
  });
}
