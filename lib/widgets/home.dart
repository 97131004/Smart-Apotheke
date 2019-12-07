import 'package:flutter/material.dart';
import 'package:maph_group3/widgets/shop.dart';
import '../util/med_list.dart';
import '../util/nampr.dart';
import '../data/globals.dart' as globals;
import '../widgets/personal.dart';
import 'scanner.dart';
import 'med_search.dart';
import 'dummy_medList.dart';
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
  @override
  void initState() {
    super.initState();

    passwordenter(context);
  }

  TextEditingController pass = new TextEditingController();
  TextEditingController ePass = new TextEditingController();
  String hash;
  Alert alert;
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
          )
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
          child:Text('Von uns empfohlene Shops und Apotheken. Ihre Medikamente Liste steht jederzeit zur Verfügung!',style: TextStyle(fontWeight:FontWeight.bold),),
          ),
          Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 50.0,right: 50.0, top: 180.0 , bottom: 50.0),
          child: RaisedButton(
            elevation: 50,
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
            onPressed: (){
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(builder: (context) =>MedSearch()),
              );},
              child: Text('Shops'),
          ),
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
          Container(
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
          ),
         
        ],
      ),
    );
  }
}
