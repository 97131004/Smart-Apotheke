import 'package:flutter/material.dart';

import '../util/med_list.dart';
import '../util/nampr.dart';
import '../data/globals.dart' as globals;
import 'scanner.dart';
import 'med_search.dart';
import 'calendar.dart';

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
            else if (curPage == Page.pass)
              buildPass()
            else if (curPage == Page.addr)
              buildAddr()
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
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          Text('Neues Passwort:'),
          TextField(
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          Text('Neues Passwort wiederholen:'),
          TextField(
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => print('button2')),
        ],
      ),
    );
  }
}
