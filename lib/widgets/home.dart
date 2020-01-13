import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/nampr.dart';
import '../widgets/personal.dart';
import 'scanner.dart';
import 'med_search.dart';
import 'recent.dart';
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
  TextEditingController passConfirm = new TextEditingController();
  final load = 'premiere';
  final buttonHeight = 100.0;
  final iconSize = 32.0;
  @override
  void initState() {
    super.initState();
    alertEula(context);
    alertPassword(context);
  }

  void alertPassword(BuildContext context) async {
    if (!(await PersonalData.isPasswordExists())) {
      Alert(
          context: context,
          title: "Setze ein Passwort",
          content: Column(
            children: <Widget>[
              TextField(
                controller: pass,
                obscureText: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: 'Passwort',
                ),
              ),
              TextField(
                controller: passConfirm,
                obscureText: true,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: 'Passwort bestätigen',
                ),
              ),
            ],
          ),
          buttons: [
            DialogButton(
              color: Colors.green,
              onPressed: () async {
                if (pass.text == passConfirm.text && pass.text.isNotEmpty) {
                  await PersonalData.setpassword(pass.text);
                  Navigator.pop(context);
                } else {
                  setState(() {
                    pass.text = '';
                    passConfirm.text = '';
                    //show error text
                  });
                }
              },
              child: Text(
                "Speichern",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();
    }
  }

  alertEula(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(load) == null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Hinweis zum Datenschutz"),
            content:
                Text("Bitte die Datenschutzerklärung lesen und bestätigen."),
            actions: <Widget>[
              FlatButton(
                child: Text("Lesen"),
                onPressed: () async {
                  await prefs.setBool(load, false);
                  Navigator.push(
                      context,
                      NoAnimationMaterialPageRoute(
                          builder: (context) => Datenschutz()));
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
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Theme.of(context).primaryColor));
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
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
                                  "Verlauf",
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
                                  builder: (context) => Recent()),
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
