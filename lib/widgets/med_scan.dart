import 'package:flutter/material.dart';

import '../util/nampr.dart';
import '../util/helper.dart';
import '../util/med_list.dart';
import '../util/load_bar.dart';
import '../util/med_get.dart';
import '../data/med.dart';
import 'med_search.dart';

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
  List<Med> display = new List<Med>();

  @override
  void initState() {
    super.initState();

    if (widget.meds != null && widget.meds.length > 0) {
      getMeds();
    } else {
      setState(() {
        getMedsDone = true;
      });
    }
  }

  Future getMeds() async {
    for (int i = 0; i < widget.meds.length; i++) {
      String pzn = widget.meds[i].pzn;
      if (Helper.isNumber(pzn)) {
        List<Med> med = await MedGet.getMeds(pzn, 0, 1);
        widget.meds[i] = med[0];
      }
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
        body: getMedsDone ? buildList() : LoadBar.build(),
      ),
    );
  }

  Widget buildList() {
    return Scrollbar(
      child: ListView.builder(
        itemBuilder: (context, index) {
          int length = widget.meds.length;
          if (index == 0) {
            //first item
            return Container(
              width: double.infinity,
              color: Colors.red[600],
              padding: EdgeInsets.all(16),
              child: Text(
                'Bitte überprüfen Sie die Korrektheit der gescannten Medikamente. ' +
                    'Wir übernehmen keine Haftung. Nutzung auf eigene Gefahr.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (length > 0 && index >= 1 && index <= length) {
            //med items
            return MedList.buildItem(context, widget.meds[index - 1]);
          }
          if (length == 0 && index == length + 1) {
            //med items
            return Text('Keine Medikamente gefunden.');
          }
          if (length > 0 && index == length + 1 ||
              length == 0 && index == length + 2) {
            //last item
            return Column(
              children: <Widget>[
                /*
                FlatButton(
                  padding: EdgeInsets.all(16),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name / PZN manuell eingeben',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed: () => gotoSearch(),
                  color: Colors.lightBlue[100],
                ),
                */
                ButtonTheme(
                  buttonColor: Colors.grey[300],
                  minWidth: double.infinity,
                  height: 50.0,
                  child: RaisedButton.icon(
                    icon: Icon(Icons.edit),
                    onPressed: () => gotoSearch(),
                    label: Text("Name / PZN manuell eingeben"),
                  ),
                ),
                ButtonTheme(
                  buttonColor: Colors.grey[100],
                  minWidth: double.infinity,
                  height: 50.0,
                  child: RaisedButton.icon(
                    icon: Icon(Icons.update),
                    onPressed: () => gotoScanner(),
                    label: Text("Nochmals scannen"),
                  ),
                ),
              ],
            );
          }
          return null;
          /*
        display.add(null);
        display.addAll(widget.meds);
        display.add(null);
        */
        },
      ),
    );
  }

  Future<bool> gotoHome() async {
    Navigator.pop(context);
    return true;
  }

  void gotoSearch() {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(builder: (context) => MedSearch()),
    );
  }

  void gotoScanner() async {
    Navigator.pop(context);
  }
}
