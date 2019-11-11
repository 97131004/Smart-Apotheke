import 'package:flutter/material.dart';

import '../util/med_list.dart';
import '../util/nampr.dart';
import '../data/med.dart';
import '../data/globals.dart' as globals;
import 'scanner.dart';
import 'med_search.dart';
import 'calendar.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  List<Med> dummy = [
    Med('Ibu ratio 400 akut Schmerztablletten Filmtabletten', '10019621',
        'http://www.beipackzettel.de/medikament/Ibu%2520ratio%2520400%2520akut%2520Schmerztablletten%2520Filmtabletten/A77827'),
    Med('Simvastatin - CT 40mg', '4144658',
        'http://www.beipackzettel.de/medikament/Simvastatin%2520-%2520CT%252040mg%2520Filmtabletten/A88644'),
  ];

  @override
  void initState() {
    super.initState();

    globals.meds = dummy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medikamente'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => gotoCalendar(),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => gotoSearch(),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () => gotoScanner(),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Text(
              'Hier kommt die History-Liste der vorher gefundenen Medikamente. Derzeit nur Dummy-Liste.'),
          MedList.build(context, globals.meds),
        ],
      ),
    );
  }

  void gotoCalendar() {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(builder: (context) => Calendar()),
    );
  }

  void gotoSearch() {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(builder: (context) => MedSearch()),
    );
  }

  void gotoScanner() {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(builder: (context) => Scanner()),
    );
  }
}
