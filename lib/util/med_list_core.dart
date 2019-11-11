import 'package:flutter/material.dart';

import '../widgets/shop.dart';
import '../widgets/med_info.dart';
import '../data/med.dart';
import 'nampr.dart';

class MedListCore {
  static Widget build(BuildContext context, List<Med> meds) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        accentColor: Colors.black, //arrow color when selected
      ),
      child: Scrollbar(
          child: ListView.builder(
        shrinkWrap: true,
        itemCount: meds.length,
        itemBuilder: (_context, index) {
          final Med item = meds[index];
          return ExpansionTile(
            backgroundColor: Colors.amber[400], //background color when selected
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  (item.name != '') ? item.name : '<PZN unbekannt>',
                  style: Theme.of(_context).textTheme.title,
                ),
                Text(
                  'PZN: ' + item.pzn,
                  style: Theme.of(_context).textTheme.subhead,
                ),
              ],
            ),
            children: <Widget>[
              if (item.name != '')
                FlatButton(
                  padding: EdgeInsets.all(16),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Beipackzettel anzeigen',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed: () => gotoMedInfo(_context, item),
                  color: Colors.white38,
                ),
              if (item.name != '')
                FlatButton(
                  padding: EdgeInsets.all(16),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bestellen',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed: () => gotoShop(_context, item),
                  color: Colors.white38,
                ),
            ],
          );
        },
      )),
    );
  }

  static void gotoMedInfo(BuildContext context, Med m) {
    if (m.url != '') {
      Navigator.push(
        context,
        NoAnimationMaterialPageRoute(builder: (context) => MedInfo(med: m)),
      );
    }
  }

  static void gotoShop(BuildContext context, Med m) {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(builder: (context) => Shop(med: m)),
    );
  }
}
