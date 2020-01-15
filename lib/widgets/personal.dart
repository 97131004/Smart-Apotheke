import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maph_group3/util/personal_data.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Personal extends StatefulWidget {
  final Function funcUpdateHome;

  Personal({Key key, this.funcUpdateHome}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PersonalState();
  }
}

enum PersonalPage { home, iban, pass, addr }

class _PersonalState extends State<Personal> {
  PersonalPage curPage = PersonalPage.home;
  String passHintText = '\u2022\u2022\u2022';
  String status = '';
  String lastOfIban = '−−';
  TextEditingController oldPass = new TextEditingController();
  TextEditingController newPass = new TextEditingController();
  TextEditingController newPassConfirm = new TextEditingController();
  TextEditingController firstName = new TextEditingController();
  TextEditingController lastName = new TextEditingController();
  TextEditingController street = new TextEditingController();
  TextEditingController postalCode = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController iban = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future getIbanAdressData() async {
    String iban = await PersonalData.getIban();
    if (iban != '') {
      setState(() {
        lastOfIban = iban.substring(
            iban.length - 2 < 0 ? 0 : iban.length - 2, iban.length);
      });
    }
    List<String> address = await PersonalData.getAddress();
    if (address != null) {
      setState(() {
        firstName.text = address[0];
        lastName.text = address[1];
        street.text = address[2];
        postalCode.text = address[3];
        city.text = address[4];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleWillPop, //back to home page, skipping scanner
      child: Scaffold(
        appBar: AppBar(
          title: Text('Persönliche Daten'),
        ),
        body: Scrollbar(
          child: ListView(
            children: <Widget>[
              if (curPage == PersonalPage.home)
                buildHome()
              else if (curPage == PersonalPage.iban)
                buildIban()
              else if (curPage == PersonalPage.addr)
                buildAddr()
              else if (curPage == PersonalPage.pass)
                buildPass()
            ],
          ),
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
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      timeInSecForIos: 1,
      fontSize: 15,
    );
  }

  void onPressedSavePassButton() async {
    bool isDone = false;
    if (newPass.text == newPassConfirm.text && newPass.text.length > 0) {
      isDone = await PersonalData.resetPassword(oldPass.text, newPass.text);
      if (isDone) {
        showToast('Passwortänderung erfolgreich.');
        handleWillPop();
        setState(() {
          newPass.clear();
          newPassConfirm.clear();
          oldPass.clear();
          status = '';
        });
      }
    }
    if (!isDone) {
      setState(() {
        newPass.clear();
        newPassConfirm.clear();
        oldPass.clear();
        status =
            'Passwortänderung fehlgeschlagen. Versuchen Sie es bitte nochmal.';
      });
    }
  }

  void onPressedSaveIbanButton() async {
    if (iban.text.isNotEmpty) {
      String ibanGet = iban.text;
      if (await PersonalData.changeIban(ibanGet, newPass.text)) {
        handleWillPop();
        showToast('Änderung der IBAN erfolgreich.');
        String ibanStr = await PersonalData.getIban();
        print(ibanStr);
        setState(() {
          newPass.clear();
          lastOfIban = ibanStr.substring(
              ibanStr.length - 2 < 0 ? 0 : ibanStr.length - 2, ibanStr.length);
          iban.clear();
          status = '';
        });
      } else {
        setState(() {
          newPass.clear();
          status = 'Passwort ist falsch. Versuchen Sie es bitte nochmal.';
        });
      }
    } else {
      setState(() {
        status = 'Geben Sie bitte eine IBAN ein.';
      });
    }
  }

  void onPressedSaveAddressButton() async {
    if (firstName.text.isEmpty ||
        lastName.text.isEmpty ||
        street.text.isEmpty ||
        postalCode.text.isEmpty ||
        city.text.isEmpty) {
      setState(() {
        status = "Bitte alle Felder ausfüllen.";
      });
    } else {
      List<String> adresse = [
        firstName.text,
        lastName.text,
        street.text,
        postalCode.text,
        city.text
      ];
      if (await PersonalData.changeAddress(adresse, newPass.text)) {
        showToast('Änderung der Adresse erfolgreich.');
        if (widget.funcUpdateHome != null) {
          widget.funcUpdateHome();
        }
        setState(() {
          newPass.clear();
          status = '';
        });
        handleWillPop();
      } else {
        setState(() {
          newPass.clear();
          status = 'Passwort ist falsch. Versuchen Sie es bitte nochmal.';
        });
      }
    }
  }

  Future<bool> handleWillPop() async {
    status = '';
    newPass.clear();
    newPassConfirm.clear();
    oldPass.clear();
    firstName.clear();
    lastName.clear();
    street.clear();
    postalCode.clear();
    city.clear();
    iban.clear();

    switch (curPage) {
      case PersonalPage.home:
        Navigator.pop(context);
        break;
      case PersonalPage.pass:
      case PersonalPage.iban:
      case PersonalPage.addr:
        setState(() {
          curPage = PersonalPage.home;
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
            getIbanAdressData();
            setState(() {
              curPage = PersonalPage.iban;
            });
          },
        ),
        ListTile(
          title: Text('Name und Adresse ändern'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            getIbanAdressData();
            setState(() {
              curPage = PersonalPage.addr;
            });
          },
        ),
        ListTile(
          title: Text('Passwort ändern'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            setState(() {
              curPage = PersonalPage.pass;
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
          Text('Aktuelle IBAN endet auf ' + lastOfIban),
          SizedBox(height: 20),
          Text('Neue IBAN: *'),
          TextField(
            controller: iban,
            decoration:
                InputDecoration(hintText: 'XXXX XXXX XXXX XXXX XXXX XX'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          Text('Zur Bestätigung aktuelles Passwort eingeben: *'),
          TextField(
            controller: newPass,
            obscureText: true,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => onPressedSaveIbanButton()),
          SizedBox(height: 20),
          Text(
            status,
            style: TextStyle(color: Theme.of(context).errorColor),
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
          Text('Vorname: *'),
          TextField(
            controller: firstName,
            decoration: InputDecoration(hintText: 'Max'),
          ),
          SizedBox(height: 20),
          Text('Name: *'),
          TextField(
            controller: lastName,
            decoration: InputDecoration(hintText: 'Mustermann'),
          ),
          SizedBox(height: 20),
          Text('Straße: *'),
          TextField(
            controller: street,
            decoration: InputDecoration(hintText: 'Musterstr. 123'),
          ),
          SizedBox(height: 20),
          Text('Postleitzahl: *'),
          TextField(
            keyboardType: TextInputType.number,
            controller: postalCode,
            decoration: InputDecoration(hintText: '12345'),
          ),
          SizedBox(height: 20),
          Text('Stadt: *'),
          TextField(
            controller: city,
            decoration: InputDecoration(hintText: 'Musterstadt'),
          ),
          SizedBox(height: 20),
          Text('Zur Bestätigung aktuelles Passwort eingeben: *'),
          TextField(
            controller: newPass,
            obscureText: true,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => onPressedSaveAddressButton()),
          SizedBox(height: 20),
          Text(
            status,
            style: TextStyle(color: Theme.of(context).errorColor),
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
          Text('Aktuelles Passwort: *'),
          TextField(
            obscureText: true,
            controller: oldPass,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          Text('Neues Passwort: *'),
          TextField(
            obscureText: true,
            controller: newPass,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          Text('Neues Passwort wiederholen: *'),
          TextField(
            obscureText: true,
            controller: newPassConfirm,
            decoration: InputDecoration(hintText: passHintText),
          ),
          SizedBox(height: 20),
          buildSaveButton(() => onPressedSavePassButton()),
          SizedBox(
            height: 20,
          ),
          Text(
            status,
            style: TextStyle(color: Theme.of(context).errorColor),
          )
        ],
      ),
    );
  }
}
