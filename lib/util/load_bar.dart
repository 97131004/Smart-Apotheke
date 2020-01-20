import 'package:flutter/material.dart';

/// Universal loading bar.

class LoadBar {
  static Widget build() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const LinearProgressIndicator(),
          const SizedBox(height: 15),
           Text(
            'Lade...',
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
      alignment: const Alignment(0.0, 0.0),
    );
  }
}