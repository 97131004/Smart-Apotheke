import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:maph_group3/util/personal_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

/// Intro page that shows on the very first app start. Shows
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
  IntroPage curPage = IntroPage.about;
  String privacyText = 'Datenschutzerklärung';
  String privacyHtml = '';
  String privacyPath = 'assets/files/privacy_policy.html';
  String eulaText = 'Nutzungsbedingungen';
  String eulaHtml = '';
  String eulaPath = 'assets/files/eula.html';
  bool agreementChecked = false;
  String passHintText = '\u2022\u2022\u2022';
  TextEditingController newPass = new TextEditingController();
  TextEditingController newPassConfirm = new TextEditingController();
  String passStatus = '';
  var appBarText = Text('');
  String keyFirstrun = 'firstRun';

  @override
  void initState() {
    super.initState();
    loadEulaPrivacy();

    if (widget.showOnlyPage != null) {
      setState(() {
        curPage = widget.showOnlyPage;
        if (widget.showOnlyPage == IntroPage.about) {
          appBarText = Text('Über uns');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Theme.of(context).primaryColor));
    return WillPopScope(
      onWillPop: handleWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: appBarText,
            leading: (widget.showOnlyPage == null &&
                    (curPage == IntroPage.eula || curPage == IntroPage.privacy))
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: handleWillPop,
                  )
                : null,
          ),
          body: (curPage == IntroPage.about)
              ? buildTitle()
              : (curPage == IntroPage.privacy)
                  ? buildEulaPrivacy(false)
                  : (curPage == IntroPage.eula)
                      ? buildEulaPrivacy(true)
                      : (curPage == IntroPage.pass)
                          ? buildPass()
                          : buildTitle()),
    );
  }

  Future<bool> handleWillPop() async {
    if (widget.showOnlyPage == null) {
      if (curPage == IntroPage.privacy || curPage == IntroPage.eula) {
        setState(() {
          appBarText = Text('');
          curPage = IntroPage.about;
        });
      } else if (curPage == IntroPage.about) {
        return true;
      }
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  Widget buildTitle() {
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
                      'Mobile Anwendungen im Gesundheitswesen\nWS 2019 / 2020\nGruppe 3\n\n' +
                      'Albert Pavlov\nAnge Toko\nMichael Franz\nPhuong Pham\nVan Tinh Chu',
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
                              text: "Ich stimme den ",
                              style: Theme.of(context).textTheme.body1),
                          TextSpan(
                            text: eulaText,
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  appBarText = Text(eulaText);
                                  curPage = IntroPage.eula;
                                });
                              },
                          ),
                          TextSpan(
                              text: " und der ",
                              style: Theme.of(context).textTheme.body1),
                          TextSpan(
                            text: privacyText,
                            style: TextStyle(
                              fontSize:
                                  Theme.of(context).textTheme.body1.fontSize,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  appBarText = Text(privacyText);
                                  curPage = IntroPage.privacy;
                                });
                              },
                          ),
                          TextSpan(
                              text: " zu.",
                              style: Theme.of(context).textTheme.body1),
                        ])),
                        value: agreementChecked,
                        onChanged: (bool value) {
                          setState(() {
                            agreementChecked = value;
                          });
                          if (agreementChecked) {
                            Future.delayed(Duration(milliseconds: 300), () {
                              setState(() {
                                appBarText = Text('Passwort setzen');
                                curPage = IntroPage.pass;
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

  void loadEulaPrivacy() async {
    privacyHtml = await rootBundle.loadString(privacyPath);
    eulaHtml = await rootBundle.loadString(eulaPath);
    setState(() {});
  }

  Widget buildEulaPrivacy([bool eula = true]) {
    setState(() {
      appBarText = Text(eula ? eulaText : privacyText);
    });
    return Scrollbar(
      child: ListView(
        children: <Widget>[
          Html(
            data: (eula ? eulaHtml : privacyHtml),
            padding: EdgeInsets.all(8.0),
            useRichText: true,
            onLinkTap: (url) async {
              if (await canLaunch(url)) {
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

  Widget buildPass() {
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
                controller: newPass,
                decoration: InputDecoration(hintText: passHintText),
              ),
              SizedBox(height: 20),
              Text('Neues Passwort wiederholen:'),
              TextField(
                obscureText: true,
                controller: newPassConfirm,
                decoration: InputDecoration(hintText: passHintText),
              ),
              SizedBox(height: 20),
              ButtonTheme(
                buttonColor: Theme.of(context).accentColor,
                minWidth: double.infinity,
                height: 40.0,
                child: RaisedButton.icon(
                  textColor: Colors.white,
                  icon: Icon(Icons.save),
                  onPressed: onPressedSavePassButton,
                  label: Text("Speichern"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                passStatus,
                style: TextStyle(color: Theme.of(context).errorColor),
              )
            ],
          ),
        ),
      ],
    ));
  }

  void onPressedSavePassButton() async {
    if (newPass.text == newPassConfirm.text && newPass.text.length > 0) {
      await PersonalData.setPassword(newPass.text);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyFirstrun, false);
      Fluttertoast.showToast(
        msg: 'Passwortänderung erfolgreich.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        timeInSecForIos: 1,
        fontSize: 15,
      );
      Navigator.push(
        context,
        NoAnimationMaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      setState(() {
        passStatus =
            'Passwörter müssen übereinstimmen, und dürfen nicht leer sein.';
      });
    }
  }
}
