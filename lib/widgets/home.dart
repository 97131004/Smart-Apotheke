import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maph_group3/util/personal_data.dart';
import 'package:maph_group3/widgets/intro.dart';
import '../util/nampr.dart';
import '../widgets/personal.dart';
import 'scanner.dart';
import 'med_search.dart';
import 'recent.dart';
import 'user_guide.dart';
import 'calendar.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    loadName();
  }

  Future loadName() async {
    List<String> address = await PersonalData.getAddress();
    if (address != null) {
      setState(() {
        firstName = address[0];
        lastName = address[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Theme.of(context).primaryColor));
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          return;
        },
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text(
                    (firstName.length > 0 && lastName.length > 0)
                        ? firstName + ' ' + lastName
                        : 'Smart Apotheke',
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
                          builder: (context) => Personal(
                                funcUpdateHome: () async {
                                  await loadName();
                                },
                              )),
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
                          builder: (context) => UserGuide()),
                    );
                  },
                ),
                ListTile(
                  title: Text('Über uns'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        NoAnimationMaterialPageRoute(
                          builder: (context) =>
                              Intro(showOnlyPage: IntroPage.about),
                        ));
                  },
                ),
                ListTile(
                  title: Text('Nutzungsbedingungen'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        NoAnimationMaterialPageRoute(
                          builder: (context) =>
                              Intro(showOnlyPage: IntroPage.eula),
                        ));
                  },
                ),
                ListTile(
                  title: Text('Datenschutzerklärung'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        NoAnimationMaterialPageRoute(
                          builder: (context) =>
                              Intro(showOnlyPage: IntroPage.privacy),
                        ));
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
                      buildButton("Kalender", Icons.calendar_today, () {
                        Navigator.push(
                          context,
                          NoAnimationMaterialPageRoute(
                              builder: (context) => Calendar()),
                        );
                      }),
                      buildButton("Medikament suchen", Icons.search, () {
                        Navigator.push(
                          context,
                          NoAnimationMaterialPageRoute(
                              builder: (context) => MedSearch()),
                        );
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      buildButton("Verlauf", Icons.history, () {
                        Navigator.push(
                          context,
                          NoAnimationMaterialPageRoute(
                              builder: (context) => Recent()),
                        );
                      }),
                      buildButton("Rezept scannen", Icons.camera_alt, () {
                        Navigator.push(
                          context,
                          NoAnimationMaterialPageRoute(
                              builder: (context) => Scanner()),
                        );
                      }),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(String label, IconData icon, Function funcOnPressed) {
    return Padding(
      padding: EdgeInsets.only(left: 4, top: 4),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width * 0.5 - 6,
        height: 100.0,
        child: RaisedButton(
          color: Theme.of(context).buttonColor,
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            if (funcOnPressed != null) funcOnPressed();
          },
        ),
      ),
    );
  }
}
