import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/home.dart';
import 'widgets/intro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Checking whether this app start is the first one.
  final String saveKeyFirstRun = 'firstRun';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool firstRun = (prefs.getBool(saveKeyFirstRun) == null ||
      (prefs.getBool(saveKeyFirstRun) != null &&
          prefs.getBool(saveKeyFirstRun)));

  /// Fixating app to portrait device orientation.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Apotheke',
      theme: ThemeData(
        /// Setting global color and text themes,
        /// which will be referred in the app code.
        appBarTheme: AppBarTheme(color: Colors.redAccent),
        accentColorBrightness: Brightness.light,
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
        primaryColor: Colors.redAccent,
        accentColor: Colors.redAccent,
        buttonColor: Colors.redAccent,
        splashColor: Colors.black54,
        errorColor: Colors.red,
        highlightColor: Colors.grey[800],
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 20.0),
          body1: TextStyle(fontSize: 15.0),
          body2: TextStyle(fontSize: 16.0),
        ),
      ),

      /// Starting [intro] page if app is run for the first time,
      /// otherwise starting [home] page.
      home: firstRun ? Intro() : Home(),
    ));
  });
}
