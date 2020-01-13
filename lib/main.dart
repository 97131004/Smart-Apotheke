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
      appBarTheme: AppBarTheme( color: Colors.green,),
      primaryColor: Colors.green,
      accentColorBrightness: Brightness.light,
      accentColor: Colors.green,
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      splashColor: Colors.black54,
      errorColor: Colors.red,
      primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),

      textTheme: TextTheme(
        headline: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        title: TextStyle(fontSize: 20.0),
        body1: TextStyle(fontSize: 15.0 ),
      ),
    ),
    home: Home(),
    //home: MedSearch(),
    //home: MedScan(meds: medicaments),
    //home: Personal(),
    //home: Shop(med: globals.meds[0]),
  ));
}
