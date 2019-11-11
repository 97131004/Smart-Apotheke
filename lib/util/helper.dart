import 'package:flutter/material.dart';

class Helper {
  static String parseMid(String source, String delim1, String delim2) {
    int iDelim1 = source.indexOf(delim1);
    int iDelim2 = source.indexOf(delim2, iDelim1 + delim1.length);
    if (iDelim1 != -1 && iDelim2 != -1) {
      return source.substring(iDelim1 + delim1.length, iDelim2);
    }
    return '';
  }

  static Widget buildLoadingBar() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const LinearProgressIndicator(),
          const SizedBox(height: 15),
          const Text(
            'Lade..',
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
      alignment: const Alignment(0.0, 0.0),
    );
  }
}
