import 'package:flutter/material.dart';

import 'data/med.dart';
import 'widgets/home.dart';

void main() {
  List<Med> medicaments = [
    Med('', '10019621'),
    Med('', '1502726'),
    Med('', 'test'),
    Med('', '00000000'),
    Med('', '01343682')
  ];

  //medicaments = [];

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'MAPH',
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
    home: Home(),
    //home: MedSearch(),
    //home: MedScan(meds: medicaments),
    //home: Personal(),
    //home: Shop(med: globals.meds[0]),
  ));
}
