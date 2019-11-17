import 'package:flutter/material.dart';

import 'widgets/home.dart';
import 'widgets/med_search.dart';

void main() {
  runApp(MaterialApp(
    title: 'MAPH',
    theme: ThemeData(
      primaryColor: Colors.lightBlue[600],
      accentColor: Colors.lightBlue[600],
      accentColorBrightness: Brightness.light,
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
    ),
    home: Home(),
    //home: MedSearch(),
  ));
}
