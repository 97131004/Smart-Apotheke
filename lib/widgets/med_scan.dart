import 'package:flutter/material.dart';
import '../util/no_internet_alert.dart';
import '../util/nampr.dart';
import '../util/helper.dart';
import '../util/med_list.dart';
import '../util/load_bar.dart';
import '../util/med_get.dart';
import '../data/med.dart';
import 'med_search.dart';

/// Page after successful scanning process. Input parameter is a [List<Med> meds],
/// which includes previously scanned medicaments. Since these only include a [pzn],
/// some post-processing is done to get the medicament [name] and leaflet [url].

class MedScan extends StatefulWidget {
  final List<Med> meds;

  MedScan({Key key, @required this.meds}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MedScanState();
  }
}

class _MedScanState extends State<MedScan> {
  /// [true] when [_getMeds] finished processing medicaments.
  bool _getMedsDone = false;

  @override
  void initState() {
    /// Checks for internet connection. If there's no connection, a
    /// [no_internet_alert] will be shown.
    Helper.hasInternet().then((internet) {
      if (internet == null || !internet) {
        NoInternetAlert.show(context);
      }
    });

    super.initState();

    /// Starting post-processing medicaments.
    if (widget.meds != null && widget.meds.length > 0) {
      _getMeds();
    } else {
      if (this.mounted) {
        setState(() {
          _getMedsDone = true;
        });
      }
    }
  }

  /// Post-processing input medicaments. Updating medicament [name] and leaflet [url].
  Future _getMeds() async {
    for (int i = 0; i < widget.meds.length; i++) {
      String pzn = widget.meds[i].pzn;
      if (Helper.isPureInteger(pzn)) {
        /// Getting remaining data based on [pzn]. Searching on page 1,
        /// since result is expected to be singular.
        List<Med> med = await MedGet.getMeds(pzn, 0, 1);
        if (med.length > 0) {
          widget.meds[i] = med[0];
        }
      }
    }

    /// Refreshing UI.
    if (this.mounted) {
      setState(() {
        _getMedsDone = true;
      });
    }

    /// Adding scanned medicaments to [globals.recentMeds] list and saving it.
    for (int i = 0; i < widget.meds.length; i++) {
      /// Skipping those, to which no medicament [name] could be found.
      if (widget.meds[i].name.length > 0) {
        Helper.recentMedsAdd(widget.meds[i]);
      }
    }
    await Helper.recentMedsSave();
  }

  /// Showing list of scanned medicaments or loading bar.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        /// Returning [true] to go back to home page, skipping scanner page.
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gefundene Medikamente'),
        ),
        body: _getMedsDone ? _buildList() : LoadBar.build(),
      ),
    );
  }

  /// Builds final list, including top note, list of scanned medicaments,
  /// buttons to do a manual medicament search or retry scan.
  Widget _buildList() {
    return Scrollbar(
      child: ListView.builder(
        itemBuilder: (context, index) {
          int length = widget.meds.length;
          if (index == 0) {
            /// Top note.
            return Container(
              width: double.infinity,
              color: Colors.blueAccent,
              padding: EdgeInsets.all(15),
              child: Text(
                'Bitte überprüfen Sie die Korrektheit der gescannten Medikamente. ' +
                    'Wir übernehmen keine Haftung. Nutzung auf eigene Gefahr.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (length > 0 && index >= 1 && index <= length) {
            /// Medicament items.
            return MedList.buildItem(context, index, widget.meds[index - 1]);
          }
          if (length == 0 && index == length + 1) {
            /// No medicament items found.
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Keine Medikamente gefunden.'),
                ),
              ],
            );
          }
          if (length > 0 && index == length + 1 ||
              length == 0 && index == length + 2) {
            /// Bottom buttons.
            return Column(
              children: <Widget>[
                SizedBox(height: 20),
                ButtonTheme(
                  buttonColor: Theme.of(context).buttonColor,
                  minWidth: MediaQuery.of(context).size.width * 0.75,
                  height: 50.0,
                  child: RaisedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        NoAnimationMaterialPageRoute(
                            builder: (context) => MedSearch()),
                      );
                    },
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Text('Name / PZN manuell eingeben',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 4),
                ButtonTheme(
                  buttonColor: Theme.of(context).buttonColor,
                  minWidth: MediaQuery.of(context).size.width * 0.75,
                  height: 50.0,
                  child: RaisedButton.icon(
                    icon: Icon(Icons.update, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    label: Text('Nochmals scannen',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
              ],
            );
          }
          return null;
        },
      ),
    );
  }
}
