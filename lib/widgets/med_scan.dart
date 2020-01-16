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
    return MedScanState();
  }
}

class MedScanState extends State<MedScan> {
  /// [true] when [getMeds] finishes processing medicaments.
  bool getMedsDone = false;

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

    /// Starting medicaments processing.
    if (widget.meds != null && widget.meds.length > 0) {
      getMeds();
    } else {
      if (this.mounted) {
        setState(() {
          getMedsDone = true;
        });
      }
    }
  }

  /// Post-processing input medicaments. Updating medicament [name] and leaflet [url].
  Future getMeds() async {
    for (int i = 0; i < widget.meds.length; i++) {
      String pzn = widget.meds[i].pzn;
      if (Helper.isNumber(pzn)) {
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
        getMedsDone = true;
      });
    }

    /// Adding scanned medicaments to [globals.meds] list and saving it.
    for (int i = 0; i < widget.meds.length; i++) {
      /// Skipping those, to which no medicament [name] could be found.
      if (widget.meds[i].name.length > 0) {
        Helper.globalMedListAdd(widget.meds[i]);
      }
    }
    await Helper.saveGlobalMedList();
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
        body: getMedsDone ? buildList() : LoadBar.build(),
      ),
    );
  }

  /// Builds final list, includes top note, list of scanned medicaments,
  /// buttons to do a manual medicament search or retry scan.
  Widget buildList() {
    return Scrollbar(
      child: ListView.builder(
        itemBuilder: (context, index) {
          int length = widget.meds.length;
          if (index == 0) {
            //first item
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
            //med items
            return MedList.buildItem(context, index, widget.meds[index - 1]);
          }
          if (length == 0 && index == length + 1) {
            //med items
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
            //last item
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
                    label: Text("Name / PZN manuell eingeben",
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
                    label: Text("Nochmals scannen",
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
