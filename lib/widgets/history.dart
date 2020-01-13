import 'package:flutter/material.dart';
import '../util/med_list.dart';
import '../data/globals.dart' as globals;
import 'package:maph_group3/data/med.dart';
import '../util/nampr.dart';
import 'scanner.dart';

class History extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryState();
  }
}

class _HistoryState extends State<History> {
  _HistoryState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geschichte'),
      ),
      body: (globals.meds.length > 0)
          ? MedList.build(
              context,
              globals.meds,
              true,
              medItemOnSwipe,
              medItemOnButtonDelete,
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Keine Medikamente vorhanden. ' +
                      'Scannen Sie ein Rezept über den Knopf unten rechts.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        child: Icon(Icons.camera_alt),
        onPressed: () {
          Navigator.push(
            context,
            NoAnimationMaterialPageRoute(builder: (context) => Scanner()),
          );
        },
      ),
    );
  }

  void medItemOnSwipe(Med med) {
    medItemDelete(med);
  }

  void medItemOnButtonDelete(Med med) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Löschen"),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(text: 'Wollen Sie den Eintrag '),
                TextSpan(
                    text: med.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' wirklich löschen?'),
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text("Nein"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Ja"),
              onPressed: () {
                medItemDelete(med);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void medItemDelete(Med med) {
    setState(() {
      globals.meds.remove(med);
    });
  }
}
