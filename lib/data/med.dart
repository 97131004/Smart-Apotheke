import 'package:flutter/material.dart';

/// Stores all the information about a medicament. Gets passed around between multiple
/// widgets. Includes medicament [name], [pzn], package leaflet [url] and whether it
/// [isHistory] (belongs to the [recent] medicaments page).

class Med {
  /// Medicament name.
  String name = '';

  /// Medicament's pzn (Pharmazentralnummer) - unique identifier. Always 8 digits long.
  String pzn = '00000000';

  /// Package leaflet url on [beipackzettel.de]. See [med_get] for further instructions.
  String url = '';

  /// Flag whether the medicament belongs to the [recent] medicaments page.
  /// A small history icon will be displayed by [med_list] if [isHistory = true].
  bool isHistory = false;

  /// Unique identifier required for internal visualization in [med_list] cross files.
  Key key;

  Med(String name, String pzn, [String url, bool isHistory]) {
    this.name = name;
    /// Filling up to 8 leading zeros.
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

  /// Converts a json string to a [med] object.
  Med.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        pzn = json['pzn'],
        url = json['url'],
        isHistory = (json['isHistory'].toLowerCase() == 'true'),
        key = Key(json['key']);

  /// Converts a [med] object to a json string.
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
