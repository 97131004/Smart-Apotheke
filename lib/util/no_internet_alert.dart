import 'package:flutter/material.dart';

import 'helper.dart';

class NoInternetAlert {
  static void show(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        int i = 1;
        return StatefulBuilder(builder: (context, setState) {
          return WillPopScope(
              onWillPop: () {},
              child: AlertDialog(
                title: Text(
                    "Kein Internet " + (i > 1 ? '(' + i.toString() + ')' : '')),
                content: Text("Bitte stellen Sie eine Internetverbindung her."),
                actions: [
                  FlatButton(
                    child: Text("Internetverbindung prüfen"),
                    onPressed: () {
                      Helper.hasInternet().then((internet) {
                        if (internet != null && internet) {
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
