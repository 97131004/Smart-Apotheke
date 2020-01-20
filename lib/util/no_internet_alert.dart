import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'helper.dart';

/// Shows a blocking modal alert box with an unavailable internet connection message.
/// This alert box cannot be dismissed. The back button is disabled. The alert box can 
/// only be dismissed after the user establishes a working internet connection.

class NoInternetAlert {
  static void show(BuildContext context) {
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
