import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'package:maph_group3/util/personaldata.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  String status = '';
  String lasofIban = '--';
  TextEditingController oldp = new TextEditingController();
  TextEditingController newp = new TextEditingController();
  TextEditingController newpW = new TextEditingController();
  TextEditingController fname = new TextEditingController();
  TextEditingController name = new TextEditingController();
  TextEditingController street = new TextEditingController();
  TextEditingController postcode = new TextEditingController();
  TextEditingController city = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getcurrentdata();
  }

  Future getcurrentdata() async {
    String iban = await PersonalData.getIban();
    if (iban != '') {
      setState(() {
        lasofIban = iban.substring(iban.length - 3<0?0:iban.length-3, iban.length);
      });
    }
    List<String> adresse = await PersonalData.getadresse();
    if (adresse != null)
      setState(() {
        fname.text = adresse[0];
        name.text = adresse[1];
        street.text = adresse[2];
        postcode.text = adresse[3];
        city.text = adresse[4];
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleWillPop, //back to home page, skipping scanner
      child: Scaffold(
        appBar: AppBar(
          title: Text('Persönliche Daten'),
          backgroundColor: Colors.green[600]
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

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.black,
        timeInSecForIos: 1,
        fontSize: 16.0);
  }

  void onPressedSavePassButton() async {
    bool isdone = false;
    if (newp.text == newpW.text && newp.text != '') {
      isdone = await PersonalData.resetPassword(oldp.text, newp.text);
      showToast('Passwortänderung erfolgreich!');
      handleWillPop();
      setState(() {
        newp.clear();
        newpW.clear();
        oldp.clear();
        status = '';
      });
    }
    if (!isdone) {
      setState(() {
        newp.clear();
        newpW.clear();
        oldp.clear();
        status =
            'Passwortänderung fehlgeschlagen. Versuchen Sie bitte nochmal!';
      });
    }
  }

  void onPressedSaveIbanButton() async {
    if (ibancontroller.text.isNotEmpty) {
      String iban = ibancontroller.text;
      if (await PersonalData.changeIban(iban, newp.text)) {
        handleWillPop();
        showToast('Änderung von IBAN erfolgreich!');
         String iban = await PersonalData.getIban();
         print(iban);
        setState(() {
          newp.clear();
          lasofIban = iban.substring(iban.length - 3 < 0? 0:iban.length-3, iban.length);
          ibancontroller.clear();
          status = '';
        });
      } else {
        setState(() {
          newp.clear();
          status = 'Passwort falsch. Versuchen Sie bitte nochmal!';
        });
      }
    } else {
      setState(() {
        status = 'Geben Sie bitte IBAN ein!';
      });
    }
  }

  void onPressedSaveAdresseButton() async {
    if (fname.text.isEmpty ||
        name.text.isEmpty ||
        street.text.isEmpty ||
        postcode.text.isEmpty ||
        city.text.isEmpty) {
      setState(() {
        status = "Bitte alle Felder ausfüllen";
      });
    } else {
      List<String> adresse = [
        fname.text,
        name.text,
        street.text,
        postcode.text,
        city.text
      ];
      if (await PersonalData.changeadresse(adresse, newp.text)) {
        showToast('Änderung von Adresse erfolgreich!');
        setState(() {
          newp.clear();
          status = '';
        });
        handleWillPop();
      } else {
        setState(() {
          newp.clear();
          status = 'Passwort falsch. Versuchen Sie bitte nochmal!';
        });
      }
    }
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

  TextEditingController ibancontroller = TextEditingController();
  Widget buildIban() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Aktuelle IBAN endet auf ' + lasofIban),
          SizedBox(height: 20),
          Text('Neue IBAN:'),
          TextField(
            controller: ibancontroller,
            decoration:
                InputDecoration(hintText: 'XXXX XXXX XXXX XXXX XXXX XX'),
          ),
          SizedBox(height: 20),
          Text('Zur Bestätigung aktuelles Passwort eingeben:'),
          TextField(
            controller: newp,
            obscureText: true,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => onPressedSaveIbanButton()),
          SizedBox(height: 20),
          Text(
            status,
            style: TextStyle(color: Colors.red),
          )
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
            controller: fname,
            decoration: InputDecoration(hintText: 'Max'),
          ),
          SizedBox(height: 20),
          Text('Name:'),
          TextField(
            controller: name,
            decoration: InputDecoration(hintText: 'Mustermann'),
          ),
          SizedBox(height: 20),
          Text('Straße:'),
          TextField(
            controller: street,
            decoration: InputDecoration(hintText: 'Musterstr. 123'),
          ),
          SizedBox(height: 20),
          Text('Postleitzahl:'),
          TextField(
            keyboardType: TextInputType.number,
            controller: postcode,
            decoration: InputDecoration(hintText: '12345'),
          ),
          SizedBox(height: 20),
          Text('Stadt:'),
          TextField(
            controller: city,
            decoration: InputDecoration(hintText: 'Musterstadt'),
          ),
          SizedBox(height: 20),
          Text('Zur Bestätigung aktuelles Passwort eingeben:'),
          TextField(
            controller: newp,
            obscureText: true,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => onPressedSaveAdresseButton()),
          SizedBox(height: 20),
          Text(
            status,
            style: TextStyle(color: Colors.red),
          )
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
            obscureText: true,
            controller: newpW,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => onPressedSavePassButton()),
          SizedBox(
            height: 20,
          ),
          Text(
            status,
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
    );
  }
}
