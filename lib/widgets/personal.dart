import 'package:flutter/material.dart';

import '../util/med_list.dart';
import '../util/nampr.dart';
import '../data/globals.dart' as globals;
import 'scanner.dart';
import 'med_search.dart';
import 'calendar.dart';
import 'package:maph_group3/util/password.dart';

class Personal extends StatefulWidget {
  Personal({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PersonalState();
  }
}

enum Page { home, iban, pass, addr }

class _PersonalState extends State<Personal> {
  Page curPage = Page.home;
  String passHintText = '\u2022\u2022\u2022';

  @override
  void initState() {
    super.initState();
  }
  String status = '';
  TextEditingController oldp = new TextEditingController();
  TextEditingController newp = new TextEditingController();
  TextEditingController newpW = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleWillPop, //back to home page, skipping scanner
      child: Scaffold(
        appBar: AppBar(
          title: Text('Persönliche Daten'),
        ),
        body: ListView(
          children: <Widget>[
            if (curPage == Page.home)
              buildHome()
            else if (curPage == Page.iban)
              buildIban()
            else if (curPage == Page.addr)
              buildAddr()
            else if (curPage == Page.pass)
              buildPass()
          ],
        ),
      ),
    );
  }

  Widget buildSaveButton(Function onPressedFunc) {
    return ButtonTheme(
      buttonColor: Theme.of(context).accentColor,
      minWidth: double.infinity,
      height: 40.0,
      child: RaisedButton.icon(
        textColor: Colors.white,
        icon: Icon(Icons.save),
        onPressed: onPressedFunc,
        label: Text("Speichern"),
      ),
    );
  }
  void onPressedSaveButton()async
  {
    bool isdone = false;
    if(newp.text == newpW.text && newp.text != '')
    {
        isdone = await Password.resetPassword(oldp.text, newp.text);
    }
    if(!isdone) {
      setState(() {
        oldp.text = '';
        newp.text = '';
        newpW.text = '';
        status = 'Passwortänderung fehlgeschlagen. Versuchen Sie bitte nochmal!';
      
      });
    };
  }
  Future<bool> handleWillPop() async {
    switch (curPage) {
      case Page.home:
        Navigator.pop(context);
        break;
      case Page.pass:
      case Page.iban:
      case Page.addr:
        setState(() {
          curPage = Page.home;
        });
        break;
    }
    return false;
  }

  Widget buildHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text('IBAN ändern'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            setState(() {
              curPage = Page.iban;
            });
          },
        ),
        ListTile(
          title: Text('Adresse ändern'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            setState(() {
              curPage = Page.addr;
            });
          },
        ),
        ListTile(
          title: Text('Passwort ändern'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            setState(() {
              curPage = Page.pass;
            });
          },
        ),
      ],
    );
  }

  Widget buildIban() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Aktuelle IBAN endet auf 99'),
          SizedBox(height: 20),
          Text('Neue IBAN:'),
          TextField(
            decoration:
                InputDecoration(hintText: 'XXXX XXXX XXXX XXXX XXXX XX'),
          ),
          SizedBox(height: 20),
          Text('Zur Bestätigung aktuelles Passwort eingeben:'),
          TextField(
            obscureText: true,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => print('button1')),
        ],
      ),
    );
  }

  Widget buildAddr() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Vorname:'),
          TextField(
            decoration: InputDecoration(hintText: 'Max'),
          ),
          SizedBox(height: 20),
          Text('Name:'),
          TextField(
            decoration: InputDecoration(hintText: 'Mustermann'),
          ),
          SizedBox(height: 20),
          Text('Postleitzahl:'),
          TextField(
            decoration: InputDecoration(hintText: '12345'),
          ),
          SizedBox(height: 20),
          Text('Stadt:'),
          TextField(
            decoration: InputDecoration(hintText: 'Musterstadt'),
          ),
          SizedBox(height: 20),
          Text('Zur Bestätigung aktuelles Passwort eingeben:'),
          TextField(
            obscureText: true,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => print('button3')),
        ],
      ),
    );
  }

  Widget buildPass() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Aktuelles Passwort:'),
          TextField(
            controller: oldp,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          Text('Neues Passwort:'),
          TextField(
            controller: newp,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          Text('Neues Passwort wiederholen:'),
          TextField(
            controller: newpW,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => onPressedSaveButton()),
          SizedBox(height: 20,),
          Text(status, style:  TextStyle(color: Colors.red),)
        ],
      ),
    );
  }
}
