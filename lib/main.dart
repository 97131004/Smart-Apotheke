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
      accentColorBrightness: Brightness.light,
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
    ),
    home: Home(),
    //home: MedSearch(),
    //home: MedScan(meds: medicaments),
    //home: Personal(),
    //home: Shop(med: globals.meds[0]),
  ));
}
