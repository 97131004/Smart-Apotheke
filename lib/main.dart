import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/home.dart';
import 'widgets/intro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyFirstrun = 'firstRun';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool firstRun = (prefs.getBool(keyFirstrun) == null ||
      (prefs.getBool(keyFirstrun) != null && prefs.getBool(keyFirstrun)));

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.redAccent));

  //fixating app to portrait-mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Apotheke',
      theme: ThemeData(
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
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 20.0),
          body1: TextStyle(fontSize: 15.0),
          body2: TextStyle(fontSize: 16.0),
        ),
      ),
      home: firstRun ? Intro() : Home(),
    ));
  });
}
