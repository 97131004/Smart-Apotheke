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

class Intro extends StatefulWidget {
  final bool showOnlyEula;

  Intro({Key key, @required this.showOnlyEula}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IntroState();
  }
}

enum Page { title, eula, pass }

class _IntroState extends State<Intro> {
  Page curPage = Page.title;
  String eulaHtml = '';
  String eulaPath = 'assets/files/privacy_policy.html';
  bool eulaChecked = false;
  String passHintText = '\u2022\u2022\u2022';
  TextEditingController newPass = new TextEditingController();
  TextEditingController newPassConfirm = new TextEditingController();
  String passStatus = '';
  var appBarText = Text('');
  String keyFirstrun = 'firstRun';

  @override
  void initState() {
    super.initState();
    loadEula();

    if (widget.showOnlyEula != null && widget.showOnlyEula) {
      setState(() {
        curPage = Page.eula;
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
          ),
          body: (curPage == Page.title)
              ? buildTitle()
              : (curPage == Page.eula)
                  ? buildEula()
                  : (curPage == Page.pass) ? buildPass() : buildTitle()),
    );
  }

  Future<bool> handleWillPop() async {
    if (widget.showOnlyEula == null || !widget.showOnlyEula) {
      if (curPage == Page.eula) {
        setState(() {
          appBarText = Text('');
          curPage = Page.title;
        });
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
                  'Mobile Applications for Public Health\nWS 2019 / 2020\nGruppe 3\n\n' +
                      'Albert Pavlov\nAnge Toko\nMichael Franz\nPhuong Pham\nVan Tinh Chu',
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ],
          ),
        ),
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
                          text: "Ich habe die ",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Datenschutzerklärung',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                appBarText = Text('Datenschutzerklärung');
                                curPage = Page.eula;
                              });
                            },
                        ),
                        TextSpan(
                          text: " durchgelesen und stimme ihr zu.",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ])),
                      value: eulaChecked,
                      onChanged: (bool value) {
                        setState(() {
                          eulaChecked = value;
                        });
                        if (eulaChecked) {
                          Future.delayed(Duration(milliseconds: 300), () {
                            setState(() {
                              appBarText = Text('Passwort setzen');
                              curPage = Page.pass;
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

  void loadEula() async {
    eulaHtml = await rootBundle.loadString(eulaPath);
    setState(() {});
  }

  Widget buildEula() {
    setState(() {
      appBarText = Text('Datenschutzerklärung');
    });
    return Scrollbar(
      child: ListView(
        children: <Widget>[
          Html(
            data: eulaHtml,
            padding: EdgeInsets.all(8.0),
            useRichText: true,
            onLinkTap: (url) async {
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                print('Could not launch $url');
              }
              print(url);
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
      await PersonalData.setpassword(newPass.text);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyFirstrun, false);
      Fluttertoast.showToast(
        msg: 'Passwortänderung erfolgreich!',
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
            'Passwörter müssen übereinstimmen, und dürfen nicht leer sein!';
      });
    }
  }
}
