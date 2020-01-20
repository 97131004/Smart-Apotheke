import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:maph_group3/util/personal_data.dart';

/// Page to change personal information, such as first and last name,
/// IBAN, address and password. Input parameter is the function [funcUpdateHome] that
/// updates the name on the [home] page.

class Personal extends StatefulWidget {
  final Function funcUpdateHome;

  Personal({Key key, this.funcUpdateHome}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PersonalState();
  }
}

enum PersonalPage { home, iban, pass, address }

class _PersonalState extends State<Personal> {
  final String _passHintText = '\u2022\u2022\u2022';

  /// Currently active subpage.
  PersonalPage _curPage = PersonalPage.home;

  /// Shows the current update status as text, e.g. error or hint messages.
  String _status = '';

  /// Shows the last 2 numbers of the IBAN. Setting the default text here,
  /// if no IBAN exists yet.
  String _lastOfIban = '−−';

  TextEditingController _oldPass = new TextEditingController();
  TextEditingController _newPass = new TextEditingController();
  TextEditingController _newPassConfirm = new TextEditingController();
  TextEditingController _firstName = new TextEditingController();
  TextEditingController _lastName = new TextEditingController();
  TextEditingController _street = new TextEditingController();
  TextEditingController _postalCode = new TextEditingController();
  TextEditingController _city = new TextEditingController();
  TextEditingController _iban = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  /// Retrieving IBAN and address data.
  Future _getIbanAdressData() async {
    String iban = await PersonalData.getIban();
    if (iban != '') {
      setState(() {
        _lastOfIban = iban.substring(
            iban.length - 2 < 0 ? 0 : iban.length - 2, iban.length);
      });
    }
    List<String> address = await PersonalData.getAddress();
    if (address != null) {
      setState(() {
        _firstName.text = address[0];
        _lastName.text = address[1];
        _street.text = address[2];
        _postalCode.text = address[3];
        _city.text = address[4];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop, //back to home page, skipping scanner
      child: Scaffold(
        appBar: AppBar(
          title: Text('Persönliche Daten'),
        ),

        /// Showing corresponding subpage.
        body: Scrollbar(
          child: ListView(
            children: <Widget>[
              if (_curPage == PersonalPage.home)
                _buildHome()
              else if (_curPage == PersonalPage.iban)
                _buildIban()
              else if (_curPage == PersonalPage.address)
                _buildAddress()
              else if (_curPage == PersonalPage.pass)
                _buildPass()
            ],
          ),
        ),
      ),
    );
  }

  /// Displays the save button.
  Widget _buildSaveButton(Function onPressedFunc) {
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

  void _showToast(String msg) {
    Helper.showToast(context, msg);
  }

  /// Sets and saves the password.
  void _onPressedSavePassButton() async {
    bool isDone = false;
    if (_newPass.text == _newPassConfirm.text && _newPass.text.length > 0) {
      isDone = await PersonalData.resetPassword(_oldPass.text, _newPass.text);
      if (isDone) {
        _showToast('Passwortänderung erfolgreich.');
        _handleWillPop();
        setState(() {
          _newPass.clear();
          _newPassConfirm.clear();
          _oldPass.clear();
          _status = '';
        });
      }
    }
    if (!isDone) {
      setState(() {
        _newPass.clear();
        _newPassConfirm.clear();
        _oldPass.clear();
        _status =
            'Passwortänderung fehlgeschlagen. Versuchen Sie es bitte nochmal.';
      });
    }
  }

  /// Sets and saves the IBAN.
  void _onPressedSaveIbanButton() async {
    if (_iban.text.isNotEmpty) {
      String ibanGet = _iban.text;
      if (await PersonalData.changeIban(ibanGet, _newPass.text)) {
        _handleWillPop();
        _showToast('Änderung der IBAN erfolgreich.');
        String ibanStr = await PersonalData.getIban();
        print(ibanStr);
        setState(() {
          _newPass.clear();
          _lastOfIban = ibanStr.substring(
              ibanStr.length - 2 < 0 ? 0 : ibanStr.length - 2, ibanStr.length);
          _iban.clear();
          _status = '';
        });
      } else {
        setState(() {
          _newPass.clear();
          _status = 'Passwort ist falsch. Versuchen Sie es bitte nochmal.';
        });
      }
    } else {
      setState(() {
        _status = 'Geben Sie bitte eine IBAN ein.';
      });
    }
  }

  /// Sets and saves the name and address.
  void _onPressedSaveAddressButton() async {
    if (_firstName.text.isEmpty ||
        _lastName.text.isEmpty ||
        _street.text.isEmpty ||
        _postalCode.text.isEmpty ||
        _city.text.isEmpty) {
      setState(() {
        _status = "Bitte alle Felder ausfüllen.";
      });
    } else {
      List<String> adresse = [
        _firstName.text,
        _lastName.text,
        _street.text,
        _postalCode.text,
        _city.text
      ];
      if (await PersonalData.changeAddress(adresse, _newPass.text)) {
        _showToast('Änderung der Adresse erfolgreich.');
        if (widget.funcUpdateHome != null) {
          widget.funcUpdateHome();
        }
        setState(() {
          _newPass.clear();
          _status = '';
        });
        _handleWillPop();
      } else {
        setState(() {
          _newPass.clear();
          _status = 'Passwort ist falsch. Versuchen Sie es bitte nochmal.';
        });
      }
    }
  }

  /// Handles back button.
  Future<bool> _handleWillPop() async {
    /// Emptying all the text boxes, so no older values persist on next push.
    _status = '';
    _newPass.clear();
    _newPassConfirm.clear();
    _oldPass.clear();
    _firstName.clear();
    _lastName.clear();
    _street.clear();
    _postalCode.clear();
    _city.clear();
    _iban.clear();

    switch (_curPage) {
      case PersonalPage.home:
        Navigator.pop(context);
        break;
      case PersonalPage.pass:
      case PersonalPage.iban:
      case PersonalPage.address:
        setState(() {
          _curPage = PersonalPage.home;
        });
        break;
    }
    return false;
  }

  /// Displays the overview subpage, which connects all the other subpage.
  Widget _buildHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text('IBAN ändern'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            _getIbanAdressData();
            setState(() {
              _curPage = PersonalPage.iban;
            });
          },
        ),
        ListTile(
          title: Text('Name und Adresse ändern'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            _getIbanAdressData();
            setState(() {
              _curPage = PersonalPage.address;
            });
          },
        ),
        ListTile(
          title: Text('Passwort ändern'),
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            setState(() {
              _curPage = PersonalPage.pass;
            });
          },
        ),
      ],
    );
  }

  /// Displays the IBAN subpage.
  Widget _buildIban() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Aktuelle IBAN endet auf ' + _lastOfIban),
          SizedBox(height: 20),
          Text('Neue IBAN: *'),
          TextField(
            controller: _iban,
            decoration:
                InputDecoration(hintText: 'XXXX XXXX XXXX XXXX XXXX XX'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          Text('Zur Bestätigung aktuelles Passwort eingeben: *'),
          TextField(
            controller: _newPass,
            obscureText: true,
            decoration: InputDecoration(hintText: _passHintText),
          ),
          SizedBox(height: 20),
          _buildSaveButton(() => _onPressedSaveIbanButton()),
          SizedBox(height: 20),
          Text(
            _status,
            style: TextStyle(color: Theme.of(context).errorColor),
          )
        ],
      ),
    );
  }

  /// Displays the name and address subpage.
  Widget _buildAddress() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Vorname: *'),
          TextField(
            controller: _firstName,
            decoration: InputDecoration(hintText: 'Max'),
          ),
          SizedBox(height: 20),
          Text('Name: *'),
          TextField(
            controller: _lastName,
            decoration: InputDecoration(hintText: 'Mustermann'),
          ),
          SizedBox(height: 20),
          Text('Straße: *'),
          TextField(
            controller: _street,
            decoration: InputDecoration(hintText: 'Musterstr. 123'),
          ),
          SizedBox(height: 20),
          Text('Postleitzahl: *'),
          TextField(
            keyboardType: TextInputType.number,
            controller: _postalCode,
            decoration: InputDecoration(hintText: '12345'),
          ),
          SizedBox(height: 20),
          Text('Stadt: *'),
          TextField(
            controller: _city,
            decoration: InputDecoration(hintText: 'Musterstadt'),
          ),
          SizedBox(height: 20),
          Text('Zur Bestätigung aktuelles Passwort eingeben: *'),
          TextField(
            controller: _newPass,
            obscureText: true,
            decoration: InputDecoration(hintText: _passHintText),
          ),
          SizedBox(height: 20),
          _buildSaveButton(() => _onPressedSaveAddressButton()),
          SizedBox(height: 20),
          Text(
            _status,
            style: TextStyle(color: Theme.of(context).errorColor),
          )
        ],
      ),
    );
  }

  /// Displays the password subpage.
  Widget _buildPass() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Aktuelles Passwort: *'),
          TextField(
            obscureText: true,
            controller: _oldPass,
            decoration: InputDecoration(hintText: _passHintText),
          ),
          SizedBox(height: 20),
          Text('Neues Passwort: *'),
          TextField(
            obscureText: true,
            controller: _newPass,
            decoration: InputDecoration(hintText: _passHintText),
          ),
          SizedBox(height: 20),
          Text('Neues Passwort wiederholen: *'),
          TextField(
            obscureText: true,
            controller: _newPassConfirm,
            decoration: InputDecoration(hintText: _passHintText),
          ),
          SizedBox(height: 20),
          _buildSaveButton(() => _onPressedSavePassButton()),
          SizedBox(
            height: 20,
          ),
          Text(
            _status,
            style: TextStyle(color: Theme.of(context).errorColor),
          )
        ],
      ),
    );
  }
}
