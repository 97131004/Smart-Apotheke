import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:maph_group3/widgets/shop.dart';
import 'package:maph_group3/data/med.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/nampr.dart';
import '../data/globals.dart' as globals;
import '../widgets/personal.dart';
import 'scanner.dart';
import 'med_search.dart';
import 'dummy_medList.dart';
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
  final load='premiere';
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

    showAlert(BuildContext context) async{
     SharedPreferences prefs =await SharedPreferences.getInstance();
     bool isfirstLoaded = prefs.getBool(load);
      // flutter defined functionc
    if ( isfirstLoaded==null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Hinweis zum Datenschutz"),
            content: new Text("Bitte die Datenshutzerlärung lesen und bestätigen"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Lesen"),
                onPressed: () {
                          
                  Navigator.push(
                                context,
                                NoAnimationMaterialPageRoute(builder: (context) =>Datenschutz()));
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
  Future.delayed(Duration.zero, ()=> showAlert(context) );
    return SafeArea(child: 
    Scaffold(
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
                color: Colors.green,
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
          ],
        ),
      ),
    
      appBar: AppBar(
        title: Text('Smart Apotheke'),
        backgroundColor: Colors.green,),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[600],
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        
        children: <Widget>[
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
      ),
      
      body: Stack(
        
        children: <Widget>[
          Container(
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/home.jpg'),fit: BoxFit.fill)),
          ),
          
          Container(
           
         padding: EdgeInsets.all(7.0),
          decoration: BoxDecoration(
                color: Colors.lightGreenAccent[100],
              ),
          child:Text(' Ihre Medikamente Liste steht jederzeit zur Verfügung!',style: TextStyle(fontWeight:FontWeight.bold),),
          ),
          Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 50.0,right: 50.0, top: 220.0 , bottom: 20.0),
          child:RaisedButton(
            elevation: 50,
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
            onPressed: (){
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(builder: (context) =>DummyMedList()),
              );},
              child: Text('Medikamente Liste'),
          ),
          ),
         /* Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 50.0,right: 50.0, top: 260.0 , bottom: 20.0),
          child:RaisedButton(
            elevation: 50,
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
            onPressed: (){
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(builder: (context) =>DummyMedList()),
              );},
              child: Text('Apotheke'),
          ),
          ),*/
         
        ],
      ),
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
              Text("Löschen"),
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

  void medItemOnButtonDelete(Med med) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Löschen"),
          content: Text("Wollen Sie diesen Eintrag wirklich löschen?"),
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
                medItemDelete(med);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void medItemDelete(Med med) {
    setState(() {
      globals.meds.remove(med);
    });
  }
}
