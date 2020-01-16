import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'helper.dart';

class NoInternetAlert {
  static void show(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color(0xFF000000).withOpacity(0)));
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        int i = 1;
        return StatefulBuilder(builder: (context, setState) {
          return WillPopScope(
              onWillPop: () {
                return;
              },
              child: AlertDialog(
                title: Text('Kein Internet vorhanden ' +
                    (i > 1 ? '(' + i.toString() + ')' : '')),
                content:
                    Text('Bitte stellen Sie eine Verbindung zum Internet her.'),
                actions: [
                  FlatButton(
                    child: Text('Internetverbindung prüfen'),
                    onPressed: () {
                      Helper.hasInternet().then((internet) {
                        if (internet != null && internet) {
                          SystemChrome.setSystemUIOverlayStyle(
                              SystemUiOverlayStyle(
                                  statusBarColor:
                                      Theme.of(context).primaryColor));
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            i++;
                          });
                        }
                      });
                    },
                  ),
                ],
              ));
        });
      },
    );
  }
}
