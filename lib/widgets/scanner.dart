import 'package:flutter/material.dart';

import 'med_list_scan.dart';
import '../util/nampr.dart';
import '../data/med.dart';

class Scanner extends StatefulWidget {
  Scanner({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ScannerState();
  }
}

class _ScannerState extends State<Scanner> {
  List<Med> medicaments = [
    Med('optionaler_name_oder_leerer_string', '10019621'),
    Med('optionaler_name_oder_leerer_string', '01502726'),
    Med('', 'test'),
    Med('', '00000000'),
    Med('optionaler_name_oder_leerer_string', '01343682')
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Rezept scannen'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Hier die Rezept-/Texterkennung durch Kamera'),
              RaisedButton(
                child: Text('Next'),
                onPressed: () => gotoMedListFound(),
              ),
            ],
          ),
        ));
  }

  void gotoMedListFound() {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(
          builder: (context) => MedListScan(meds: medicaments)),
    );
  }
}
