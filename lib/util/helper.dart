import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:connectivity/connectivity.dart';

import 'package:http/http.dart' as http;


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

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
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
      print(body);
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

  static Future<String> fetchHTML(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200)
      return response.body;
    else return null;
  }

  static String jsonDecode(String data) {
    return jsonDecode(data);
  }


  static String privacypolicy = """
<!DOCTYPE html>
    <html>
    <head>
      <meta charset='utf-8'>
      <meta name='viewport' content='width=device-width'>
      <title>Privacy Policy</title>
      <style> body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding:1em; } </style>
    </head>
    <body>
    <h2>Privacy Policy</h2> <p>
                    HTW Berlin AI Master Group 2019 built the SmartApotheke app as
                    a Free app. This SERVICE is provided by
                    HTW Berlin AI Master Group 2019 at no cost and is intended for
                    use as is.
                  </p> <p>
                    This page is used to inform visitors regarding
                    my policies with the collection, use, and
                    disclosure of Personal Information if anyone decided to use
                    my Service.
                  </p> <p>
                    If you choose to use my Service, then you agree
                    to the collection and use of information in relation to this
                    policy. The Personal Information that I collect is
                    used for providing and improving the Service.
                    I will not use or share your
                    information with anyone except as described in this Privacy
                    Policy.
                  </p> <p>
                    The terms used in this Privacy Policy have the same meanings
                    as in our Terms and Conditions, which is accessible at
                    SmartApotheke unless otherwise defined in this Privacy
                    Policy.
                  </p> <p><strong>Information Collection and Use</strong></p> <p>
                    For a better experience, while using our Service,
                    I may require you to provide us with certain
                    personally identifiable information. The
                    information that I request will be
                    retained on your device and is not collected by me in any way.
                  </p> <p>
                    The app does use third party services that may collect
                    information used to identify you.
                  </p> <div><p>
                      Link to privacy policy of third party service providers
                      used by the app
                    </p> <ul><li><a href="https://www.google.com/policies/privacy/" target="_blank">Google Play Services</a></li><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----></ul></div> <p><strong>Log Data</strong></p> <p>
                    I want to inform you that whenever
                    you use my Service, in a case of an error in the
                    app I collect data and information (through third
                    party products) on your phone called Log Data. This Log Data
                    may include information such as your device Internet
                    Protocol (“IP”) address, device name, operating system
                    version, the configuration of the app when utilizing
                    my Service, the time and date of your use of the
                    Service, and other statistics.
                  </p> <p><strong>Cookies</strong></p> <p>
                    Cookies are files with a small amount of data that are
                    commonly used as anonymous unique identifiers. These are
                    sent to your browser from the websites that you visit and
                    are stored on your device's internal memory.
                  </p> <p>
                    This Service does not use these “cookies” explicitly.
                    However, the app may use third party code and libraries that
                    use “cookies” to collect information and improve their
                    services. You have the option to either accept or refuse
                    these cookies and know when a cookie is being sent to your
                    device. If you choose to refuse our cookies, you may not be
                    able to use some portions of this Service.
                  </p> <p><strong>Service Providers</strong></p> <p>
                    I may employ third-party companies
                    and individuals due to the following reasons:
                  </p> <ul><li>To facilitate our Service;</li> <li>To provide the Service on our behalf;</li> <li>To perform Service-related services; or</li> <li>To assist us in analyzing how our Service is used.</li></ul> <p>
                    I want to inform users of this
                    Service that these third parties have access to your
                    Personal Information. The reason is to perform the tasks
                    assigned to them on our behalf. However, they are obligated
                    not to disclose or use the information for any other
                    purpose.
                  </p> <p><strong>Security</strong></p> <p>
                    I value your trust in providing us
                    your Personal Information, thus we are striving to use
                    commercially acceptable means of protecting it. But remember
                    that no method of transmission over the internet, or method
                    of electronic storage is 100% secure and reliable, and
                    I cannot guarantee its absolute security.
                  </p> <p><strong>Links to Other Sites</strong></p> <p>
                    This Service may contain links to other sites. If you click
                    on a third-party link, you will be directed to that site.
                    Note that these external sites are not operated by
                    me. Therefore, I strongly advise you to
                    review the Privacy Policy of these websites.
                    I have no control over and assume no
                    responsibility for the content, privacy policies, or
                    practices of any third-party sites or services.
                  </p> <p><strong>Children’s Privacy</strong></p> <p>
                    These Services do not address anyone under the age of 13.
                    I do not knowingly collect personally
                    identifiable information from children under 13. In the case
                    I discover that a child under 13 has provided
                    me with personal information,
                    I immediately delete this from our servers. If you
                    are a parent or guardian and you are aware that your child
                    has provided us with personal information, please contact
                    me so that I will be able to do
                    necessary actions.
                  </p> <p><strong>Changes to This Privacy Policy</strong></p> <p>
                    I may update our Privacy Policy from
                    time to time. Thus, you are advised to review this page
                    periodically for any changes. I will
                    notify you of any changes by posting the new Privacy Policy
                    on this page. These changes are effective immediately after
                    they are posted on this page.
                  </p> <p><strong>Contact Us</strong></p> <p>
                    If you have any questions or suggestions about
                    my Privacy Policy, do not hesitate to contact
                    me at HTW Berlin .
                  </p> <p>
                    This privacy policy page was created at
                    <a href="https://privacypolicytemplate.net" target="_blank">privacypolicytemplate.net</a>
                    and modified/generated by
                    <a href="https://app-privacy-policy-generator.firebaseapp.com/" target="_blank">App Privacy Policy Generator</a></p>
    </body>
    </html>
      """;
}
