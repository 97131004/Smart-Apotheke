import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:maph_group3/util/personal_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

/// Intro page is shown on the very first app start. Includes subpages for
/// information about the app, privacy policy, eula and initial password prompt.
/// Switches subpages by changing the [_curPage] enum. Input parameter [showOnlyPage]
/// defines which of the subpages should be shown (called from the [home] page).

class Intro extends StatefulWidget {
  final IntroPage showOnlyPage;

  Intro({Key key, this.showOnlyPage}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IntroState();
  }
}

enum IntroPage { about, privacy, eula, pass }

class _IntroState extends State<Intro> {
  /// Currently active subpage.
  IntroPage _curPage = IntroPage.about;

  String _appBarTitle = '';

  /// Used to change [_appBarTitle] on demand.
  final String _privacyTitle = 'Datenschutzerklärung';
  final String _privacyPath = 'assets/files/privacy_policy.html';

  /// Used to change [_appBarTitle] on demand.
  final String _eulaTitle = 'Nutzungsbedingungen';
  final String _eulaPath = 'assets/files/eula.html';

  final String _passHintText = '\u2022\u2022\u2022';
  final String _saveKeyFirstRun = 'firstRun';

  /// Storing retrieved privacy policy html.
  String _privacyHtml = '';

  /// Storing retrieved eula html.
  String _eulaHtml = '';

  bool _agreementChecked = false;

  TextEditingController _newPass = new TextEditingController();
  TextEditingController _newPassConfirm = new TextEditingController();

  /// Error text on wrongly entered password.
  String _passStatus = '';

  @override
  void initState() {
    super.initState();

    _loadEulaPrivacy();

    if (widget.showOnlyPage != null) {
      setState(() {
        _curPage = widget.showOnlyPage;
        if (widget.showOnlyPage == IntroPage.about) {
          _appBarTitle = 'Über uns';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(_appBarTitle),
            leading: (widget.showOnlyPage == null &&
                    (_curPage == IntroPage.eula ||
                        _curPage == IntroPage.privacy))
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: _handleWillPop,
                  )
                : null,
          ),

          /// Showing corresponding subpage.
          body: (_curPage == IntroPage.about)
              ? _buildAbout()
              : (_curPage == IntroPage.privacy)
                  ? _buildEulaPrivacy(false)
                  : (_curPage == IntroPage.eula)
                      ? _buildEulaPrivacy(true)
                      : (_curPage == IntroPage.pass)
                          ? _buildPass()
                          : _buildAbout()),
    );
  }

  /// Handles back button.
  Future<bool> _handleWillPop() async {
    if (widget.showOnlyPage == null) {
      if (_curPage == IntroPage.privacy || _curPage == IntroPage.eula) {
        setState(() {
          _appBarTitle = '';
          _curPage = IntroPage.about;
        });
      } else if (_curPage == IntroPage.about) {
        /// Moves app to background.
        return true;
      }
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  /// Displays information about the app, its developers and agreement checkbox.
  Widget _buildAbout() {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Smart Apotheke',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 38,
                  )),
              SizedBox(height: 15),
              Text(
                  'Hochschule für Technik und Wirtschaft Berlin\n' +
                      '' +
                      '',
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ],
          ),
        ),
        if (!(widget.showOnlyPage != null &&
            widget.showOnlyPage == IntroPage.about))
          Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Theme(
                      data: ThemeData(highlightColor: Colors.white),
                      child: CheckboxListTile(
                        title: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: 'Ich stimme den ',
                              style: Theme.of(context).textTheme.body1),
                          TextSpan(
                            text: _eulaTitle,
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  _appBarTitle = _eulaTitle;
                                  _curPage = IntroPage.eula;
                                });
                              },
                          ),
                          TextSpan(
                              text: ' und der ',
                              style: Theme.of(context).textTheme.body1),
                          TextSpan(
                            text: _privacyTitle,
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  _appBarTitle = _privacyTitle;
                                  _curPage = IntroPage.privacy;
                                });
                              },
                          ),
                          TextSpan(
                              text: ' zu.',
                              style: Theme.of(context).textTheme.body1),
                        ])),
                        value: _agreementChecked,
                        onChanged: (bool value) {
                          setState(() {
                            _agreementChecked = value;
                          });
                          if (_agreementChecked) {
                            /// Pushing to [home] page after checkbox check.
                            Future.delayed(Duration(milliseconds: 300), () {
                              setState(() {
                                _appBarTitle = 'Passwort setzen';
                                _curPage = IntroPage.pass;
                              });
                            });
                          }
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    )
                  ]))
      ],
    );
  }

  /// Loading eula and privacy policy from html files.
  void _loadEulaPrivacy() async {
    _privacyHtml = await rootBundle.loadString(_privacyPath);
    _eulaHtml = await rootBundle.loadString(_eulaPath);
    setState(() {});
  }

  /// Displays eula and privacy policy.
  Widget _buildEulaPrivacy([bool eula = true]) {
    setState(() {
      _appBarTitle = (eula ? _eulaTitle : _privacyTitle);
    });
    return Scrollbar(
      child: ListView(
        children: <Widget>[
          Html(
            data: (eula ? _eulaHtml : _privacyHtml),
            padding: EdgeInsets.all(8.0),
            useRichText: true,
            onLinkTap: (url) async {
              if (await canLaunch(url)) {
                /// Using [launch] function without parameters to open the website in a separate
                /// browser app window. Embedding the browser window into the app makes it 
                /// almost impossible to return back to the app (using the back button), 
                /// since google's websites automatically forward the user to other pages
                /// within their servers.
                await launch(url);
              } else {
                print('Could not launch $url');
              }
            },
          )
        ],
      ),
    );
  }

  /// Displays initial password prompt.
  Widget _buildPass() {
    return Scrollbar(
        child: ListView(
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.blueAccent,
          padding: EdgeInsets.all(15),
          child: Text(
            'Zum Bestellen von Medikamenten aus der App wird ein Passwort benötigt. ' +
                'Bitte setzen Sie ein neues Passwort.',
            style: TextStyle(color: Colors.white),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text('Neues Passwort:'),
              TextField(
                obscureText: true,
                controller: _newPass,
                decoration: InputDecoration(hintText: _passHintText),
              ),
              SizedBox(height: 20),
              Text('Neues Passwort wiederholen:'),
              TextField(
                obscureText: true,
                controller: _newPassConfirm,
                decoration: InputDecoration(hintText: _passHintText),
              ),
              SizedBox(height: 20),
              ButtonTheme(
                buttonColor: Theme.of(context).accentColor,
                minWidth: double.infinity,
                height: 40.0,
                child: RaisedButton.icon(
                  textColor: Colors.white,
                  icon: Icon(Icons.save),
                  onPressed: _onPressedSavePassButton,
                  label: Text('Speichern'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                _passStatus,
                style: TextStyle(color: Theme.of(context).errorColor),
              )
            ],
          ),
        ),
      ],
    ));
  }

  /// Saves password, shows toast note, saves [_saveKeyFirstRun] flag ([intro] page
  /// is completed at this point and should not be opened on next app start),
  /// then pushes to [home] page.
  void _onPressedSavePassButton() async {
    if (_newPass.text == _newPassConfirm.text && _newPass.text.length > 0) {
      await PersonalData.setPassword(_newPass.text);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_saveKeyFirstRun, false);
      Helper.showToast(context, 'Passwortänderung erfolgreich.');

      /// [Navigator.pushReplacement] replaces the current [intro] page with the [home] page.
      /// This way, pressing the back button from the [home] page won't go to the [intro] page.
      Navigator.pushReplacement(
        context,
        NoAnimationMaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      setState(() {
        _passStatus =
            'Passwörter müssen übereinstimmen, und dürfen nicht leer sein.';
      });
    }
  }
}
