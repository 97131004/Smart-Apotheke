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
import 'package:steel_crypt/steel_crypt.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    passwordenter();
  }

  TextEditingController pass = new TextEditingController();
  TextEditingController ePass = new TextEditingController();
  String hash;
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return new File('$path/db.txt');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();
      return body;
    } catch (e) {
      await writeData('');
      return 'The file <db.txt> dont exists. Creating a new one....';
    }
  }

  Future<File> writeData(String data) async {
    final file = await localFile;
    return file.writeAsString('$data');
  }

  passwordenter() async {
    Alert alert = await createAlert(context);
    SchedulerBinding.instance
        .addPostFrameCallback(alert == null ? null : (_) => alert.show());
  }

  Future<Alert> createAlert(BuildContext context) async {
    String hash = await readData();
    print(hash);
    if (hash.isEmpty) {
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
              onPressed: () => _submitpasswort(),
              child: Text(
                "SUBMIT",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]);
      return alert;
    } else
      return null;
  }

  Future _submitpasswort() async {
    if (pass.text == ePass.text && pass.text.isNotEmpty) {
      var hasher = HashCrypt("SHA-3/512");
      String hash = hasher.hash(pass.text);
      await writeData(hash);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
