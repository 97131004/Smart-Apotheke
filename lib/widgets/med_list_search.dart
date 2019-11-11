import 'package:flutter/material.dart';

class MedListSearch extends StatefulWidget {
  MedListSearch({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedListSearchState();
  }
}

class _MedListSearchState extends State<MedListSearch> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medikament suchen'),
      ),
      body: Text(
          'Hier Medikament nach Name/PZN online suchen und Suchergebnisse anzeigen (evtl auch gleichzeitig in der app.dart history-liste suchen und das ergebnis hier über den online-ergebnissen anzeigen)'),
    );
  }
}
