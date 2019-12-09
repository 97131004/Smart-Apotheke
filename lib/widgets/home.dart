import 'package:flutter/material.dart';
import 'package:maph_group3/data/med.dart';
import '../util/med_list.dart';
import '../util/nampr.dart';
import '../data/globals.dart' as globals;
import '../widgets/personal.dart';
import 'scanner.dart';
import 'med_search.dart';
import 'calendar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:maph_group3/util/personaldata.dart';

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
                '<Vorname> <Name>',
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
          ),
        ],
      ),
      body: (globals.meds.length > 0)
          ? MedList.build(
              context,
              globals.meds,
              true,
              medItemOnLongPress,
              medItemOnSwipe,
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

  void medItemOnLongPress(Med med, Offset tapPosition) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: <Widget>[
              Icon(Icons.delete),
              Text("Delete"),
            ],
          ),
        )
      ],
      context: context,
      position: RelativeRect.fromRect(
          tapPosition & Size.zero, Offset.zero & overlay.size),
    ).then((value) {
      if (value == 'delete') {
        medItemDelete(med);
      }
    });
  }

  void medItemOnSwipe(Med med) {
    medItemDelete(med);
  }

  void medItemDelete(Med med) {
    setState(() {
      globals.meds.remove(med);
    });
  }
}
