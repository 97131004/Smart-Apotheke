import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:maph_group3/widgets/shop.dart';
import 'package:maph_group3/data/med.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/nampr.dart';
import '../data/globals.dart' as globals;
import '../widgets/personal.dart';
import 'scanner.dart';
import 'med_search.dart';
import 'history.dart';
import 'userguide.dart';
import 'datenschutzerklaerung.dart';
import 'calendar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:maph_group3/util/personal_data.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  TextEditingController pass = new TextEditingController();
  TextEditingController ePass = new TextEditingController();
  String hash;
  Alert alert;
  final load = 'premiere';
  final buttonHeight = 100.0;
  final iconSize = 32.0;
  @override
  void initState() {
    super.initState();
    passwordenter(context);
  }

  void passwordenter(BuildContext context) async {
    if (!(await PersonalData.isPasswordExists())) {
      alert = createAlert(context);
      alert.show();
    }
  }

  Alert createAlert(BuildContext context) {
    var alert = Alert(
        context: context,
        title: "SET YOUR PASSWORD",
        content: Column(
          children: <Widget>[
            TextField(
              controller: pass,
              obscureText: true,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Password',
              ),
            ),
            TextField(
              controller: ePass,
              obscureText: true,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Re-entered Password',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.green,
            onPressed: () => _submitpasswort(),
            child: Text(
              "SUBMIT",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]);
    return alert;
  }

  Future _submitpasswort() async {
    //bool isdone = false;
    if (pass.text == ePass.text && pass.text.isNotEmpty) {
      await PersonalData.setpassword(pass.text);
      Navigator.pop(context);
    } else {
      setState(() {
        pass.text = '';
        ePass.text = '';
      });
    }
  }

  showAlert(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isfirstLoaded = prefs.getBool(load);
    // flutter defined functionc
    if (isfirstLoaded == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Hinweis zum Datenschutz"),
            content:
                new Text("Bitte die Datenshutzerlärung lesen und bestätigen"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Lesen"),
                onPressed: () {
                  Navigator.push(
                      context,
                      NoAnimationMaterialPageRoute(
                          builder: (context) => Datenschutz()));
                  prefs.setBool(load, false);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showAlert(context));
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Theme.of(context).primaryColor));
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  '<Vorname> <Name>',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              ListTile(
                title: Text('Persönliche Daten'),
                onTap: () {
                  //closing menu first, so it eliminates flicker for the next pop
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    NoAnimationMaterialPageRoute(
                        builder: (context) => Personal()),
                  );
                },
              ),
              ListTile(
                title: Text('User Guide'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    NoAnimationMaterialPageRoute(
                        builder: (context) => Userguide()),
                  );
                },
              ),
              ListTile(
                title: Text('Über uns'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Datenschutzerklärung'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    NoAnimationMaterialPageRoute(
                        builder: (context) => Datenschutz()),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Smart Apotheke'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 4, top: 4),
                      child: ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width * 0.5 - 6,
                        height: buttonHeight,
                        child: RaisedButton(
                          color: Theme.of(context).buttonColor,
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  "Kalender",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              NoAnimationMaterialPageRoute(
                                  builder: (context) => Calendar()),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4, top: 4),
                      child: ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width * 0.5 - 6,
                        height: buttonHeight,
                        child: RaisedButton(
                          color: Theme.of(context).buttonColor,
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  "Medikament suchen",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              NoAnimationMaterialPageRoute(
                                  builder: (context) => MedSearch()),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 4, top: 4),
                      child: ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width * 0.5 - 6,
                        height: buttonHeight,
                        child: RaisedButton(
                          color: Theme.of(context).buttonColor,
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.history,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  "Geschichte",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              NoAnimationMaterialPageRoute(
                                  builder: (context) => History()),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4, top: 4),
                      child: ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width * 0.5 - 6,
                        height: buttonHeight,
                        child: RaisedButton(
                          color: Theme.of(context).buttonColor,
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  "Rezept scannen",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              NoAnimationMaterialPageRoute(
                                  builder: (context) => Scanner()),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
