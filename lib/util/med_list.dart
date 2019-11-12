import 'package:flutter/material.dart';

import '../widgets/shop.dart';
import '../widgets/med_info.dart';
import '../data/med.dart';
import 'nampr.dart';

class MedList {
  static List<Med> medicaments;

  static Widget build(BuildContext context, List<Med> meds) {
    medicaments = meds;

    return Scrollbar(
        child: ListView.builder(
      shrinkWrap: true,
      itemCount: meds.length,
      itemBuilder: _buildItem,
    ));
  }

  static Widget _buildItem(BuildContext context, int index) {
    final Med item = medicaments[index];
    return buildItem(context, item, index);
  }

  static Widget buildItem(BuildContext context, Med item, int index) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        accentColor: Colors.black, //arrow color when selected
      ),
      child: ExpansionTile(
        backgroundColor: Colors.amber[400], //background color when selected
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              (item.name != '') ? item.name : '<PZN unbekannt>',
              style: Theme.of(context).textTheme.title,
            ),
            Text(
              'PZN: ' + item.pzn,
              style: Theme.of(context).textTheme.subhead,
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
              onPressed: () => gotoMedInfo(context, item),
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
              onPressed: () => gotoShop(context, item),
              color: Colors.white38,
            ),
        ],
      ),
    );
  }

  static void gotoMedInfo(BuildContext context, Med m) {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(builder: (context) => MedInfo(med: m)),
    );
  }

  static void gotoShop(BuildContext context, Med m) {
    Navigator.push(
      context,
      NoAnimationMaterialPageRoute(builder: (context) => Shop(med: m)),
    );
  }
}
