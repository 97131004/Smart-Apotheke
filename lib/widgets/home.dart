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

/// Default home page, that opens on each app start, except the very first time.
/// Shows buttons for app's primary functions and a hamburger menu with other settings.
class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  /// First name will be displayed in the menu header.
  String firstName = '';

  /// Last name will be displayed in the menu header.
  String lastName = '';

  @override
  void initState() {
    super.initState();
    loadName();
  }

  /// Loading first and last name from the [personal] settings.
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
        onWillPop: () async {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return false;
        },
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                /// Menu header.
                /// Displaying first and last name.
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

                /// Menu buttons.
                ListTile(
                  title: Text('Persönliche Daten'),
                  onTap: () {
                    /// Popping menu first, so it eliminates flicker for the next page pop.
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      NoAnimationMaterialPageRoute(

                          /// Passing [loadName] function to update first and last name
                          /// in [home] page's menu header from within [personal] page.
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

          /// Main buttons.
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

  /// Visualizing main button.
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
