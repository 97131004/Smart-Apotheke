import 'package:flutter/material.dart';
import 'package:maph_group3/widgets/med_search.dart';
import '../widgets/shop.dart';
import '../widgets/med_info.dart';
import '../data/med.dart';
import 'nampr.dart';

class MedList {
  static Widget build(BuildContext context, List<Med> meds,
      [bool removable = false,
      Function(Med) onSwipe,
      Function(Med) onButtonDelete]) {
    return Scrollbar(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: meds.length,
          itemBuilder: (context, index) {
            return buildItem(context, index, meds[index], removable, onSwipe,
                onButtonDelete);
          }),
    );
  }

  static Offset tapPosition;
  static void storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }

  static Widget buildItem(BuildContext context, int index, Med item,
      [bool removable = false,
      Function(Med) onSwipe,
      Function(Med) onButtonDelete]) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        accentColor: Colors.black, //arrow color when selected
      ),
      child: (removable)
          ? GestureDetector(
              onTapDown: storePosition,
              child: Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  if (onSwipe != null) {
                    onSwipe(item);
                  }
                },
                child: buildItemCore(context, item, removable, onButtonDelete),
              ),
            )
          : buildItemCore(context, item, removable, onButtonDelete),
    );
  }

  static Widget buildItemCore(BuildContext context, Med item, bool removable,
      Function(Med) onButtonDelete) {
    return ExpansionTile(
      key: new PageStorageKey<Key>(item.key),
      backgroundColor: Color(0xffFFD4D4), //background color when selected
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              if (item.isHistory && item.name.length > 0)
                Icon(
                  Icons.history,
                  size: 25,
                ),
              Padding(
                padding: EdgeInsets.only(
                    left: (item.isHistory && item.name.length > 0) ? 30 : 0),
                child: Text(
                  (item.name.length > 0) ? item.name : '<PZN unbekannt>',
                  style: Theme.of(context).textTheme.title,
                ),
              )
            ],
          ),
          Text(
            'PZN: ' + item.pzn,
            style: Theme.of(context).textTheme.subhead,
          ),
        ],
      ),
      children: <Widget>[
        if (item.name.length > 0)
          FlatButton(
            padding: EdgeInsets.all(16),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Beipackzettel anzeigen',
                style: Theme.of(context).textTheme.body2,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (context) => MedInfo(med: item)),
              );
            },
            color: Colors.white38,
          ),
        if (item.name.length > 0)
          FlatButton(
            padding: EdgeInsets.all(16),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bestellen',
                style: Theme.of(context).textTheme.body2,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(
                    builder: (context) => Shop(med: item)),
              );
            },
            color: Colors.white38,
          ),
        if (item.name.length > 0 && removable)
          FlatButton(
            padding: EdgeInsets.all(16),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Löschen',
                style: Theme.of(context).textTheme.body2,
              ),
            ),
            onPressed: () {
              if (onButtonDelete != null) {
                onButtonDelete(item);
              }
              return;
            },
            color: Colors.white38,
          ),
        if (item.name.length <= 0)
          FlatButton(
            padding: EdgeInsets.all(16),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Name / PZN manuell eingeben',
                style: Theme.of(context).textTheme.body2,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                NoAnimationMaterialPageRoute(builder: (context) => MedSearch()),
              );
            },
            color: Colors.white38,
          ),
      ],
    );
  }
}
