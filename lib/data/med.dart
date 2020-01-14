import 'package:flutter/material.dart';

class Med {
  String name = '';
  String pzn = '00000000';
  String url = '';
  bool isHistory = false;
  Key key;

  Med(String name, String pzn, [String url, bool isHistory]) {
    this.name = name;
    while (pzn.length < 8) {
      pzn = '0' + pzn;
    }
    this.pzn = pzn;
    if (url != null && url.length > 0) {
      this.url = url;
    }
    if (isHistory != null) {
      this.isHistory = isHistory;
    }
    this.key = UniqueKey();
  }

  Med.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        pzn = json['pzn'],
        url = json['url'],
        isHistory = (json['isHistory'].toLowerCase() == 'true'),
        key = Key(json['key']);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pzn': pzn,
      'url': url,
      'isHistory': isHistory.toString(),
      'key': key.toString(),
    };
  }
}
