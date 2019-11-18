import 'package:flutter/material.dart';

import '../util/med_list.dart';
import '../util/load_bar.dart';
import '../util/med_get.dart';
import '../data/med.dart';

class MedScan extends StatefulWidget {
  final List<Med> meds;

  MedScan({Key key, @required this.meds}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedScanState();
  }
}

class _MedScanState extends State<MedScan> {
  bool getMedsDone = false;

  @override
  void initState() {
    super.initState();

    if (widget.meds != null && widget.meds.length > 0) {
      getMeds();
    } else {
      //
      print('no meds passed');
      //
    }
  }

  Future getMeds() async {
    for (int i = 0; i < widget.meds.length; i++) {
      await MedGet.getMed(widget.meds[i]);
    }
    setState(() {
      getMedsDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: gotoHome, //back to home page, skipping scanner
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gefundene Medikamente'),
        ),
        body: Container(
            alignment: Alignment.center,
            //Text('Hier die Rezept-/Texterkennung durch Kamera'),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  getMedsDone
                      ? MedList.build(context, widget.meds)
                      : LoadBar.build(),
                  RaisedButton.icon(
                    icon: Icon(Icons.update),
                    onPressed: () {
                      Navigator.pop(context);
                    }, label: Text("Try again"),
                  )
                ])),
      ),
    );
  }

  Future<bool> gotoHome() async {
    Navigator.pop(context);
    return true;
  }
}
