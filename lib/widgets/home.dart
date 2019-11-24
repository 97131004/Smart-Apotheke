import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../util/med_list.dart';
import '../util/nampr.dart';
import '../data/globals.dart' as globals;
import '../widgets/personal.dart';
import 'scanner.dart';
import 'med_search.dart';
import 'calendar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:maph_group3/util/password.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home>  {
  @override
  Future initState()  {
    super.initState();
    passwordenter(context);
  }

  TextEditingController pass = new TextEditingController();
  TextEditingController ePass = new TextEditingController();
  String hash;
  String status = '';
 
  void passwordenter(BuildContext context) async {
    if (!(await Password.isPasswordExists())) {
      Alert alert = createAlert(context);
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
            Text(
              status,
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
        buttons: [
          DialogButton(
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
    bool isdone = false;
    if (pass.text == ePass.text && pass.text.isNotEmpty) {
      if (await Password.setpassword(pass.text)) {
        isdone = true;
        Navigator.pop(context);
      }
    }
    if (!isdone) {
      setState(() {
        pass.text = '';
        ePass.text = '';
        status = 'Setting password is failed! Please try again';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Future.delayed(Duration.zero, () => passwordenter(context));
    //passwordenter();
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                '<Appname>',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
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
              title: Text('User Guide?'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Datenschutzerkärung'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Über uns'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Medikamente'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(builder: (context) => Calendar()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(builder: (context) => MedSearch()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(builder: (context) => Scanner()),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Text(
              'Hier kommt die History-Liste der vorher gefundenen Medikamente. Derzeit nur Dummy-Liste.'),
          MedList.build(context, globals.meds),
        ],
      ),
    );
  }
}
