import 'package:flutter/material.dart';
import 'package:maph_group3/util/helper.dart';
import '../util/med_list.dart';
import '../data/globals.dart' as globals;
import 'package:maph_group3/data/med.dart';
import '../util/nampr.dart';
import 'scanner.dart';

/// Page that displays a list of recently scanned or bought medicaments.
/// Each medicament entry is drawn by [MedList.build].

class Recent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RecentState();
  }
}

class _RecentState extends State<Recent> {
  _RecentState();

  @override
  void initState() {
    super.initState();

    _getGlobalMedList();
  }

  /// Retrieving [globals.recentMeds] list, which represents a list of recent medicaments.
  Future _getGlobalMedList() async {
    if (this.mounted) {
      await Helper.recentMedsLoad();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verlauf'),
      ),
      body: (globals.recentMeds.length > 0)
          ? MedList.build(
              context,

              /// Displays list in reverse, so we will see the latest medicament on top.
              globals.recentMeds.reversed.toList(),
              true,
              _medItemOnSwipe,
              _medItemOnButtonDelete,
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

  /// Deletes medicament entry on swipe.
  void _medItemOnSwipe(Med med) {
    _medItemDelete(med);
  }

  /// Deletes medicament entry on alert box confirmation.
  void _medItemOnButtonDelete(Med med) {
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
                _medItemDelete(med);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// Removes medicament entry from the [globals.recentMeds] list and saves it.
  void _medItemDelete(Med med) async {
    setState(() {
      globals.recentMeds.remove(med);
    });
    await Helper.recentMedsSave();
  }
}
