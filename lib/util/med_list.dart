import 'package:flutter/material.dart';
import 'package:maph_group3/widgets/med_search.dart';
import '../widgets/shop.dart';
import '../widgets/med_info.dart';
import '../data/med.dart';
import 'nampr.dart';

/// Functions to visualize a list of [med] objects across multiple pages of the app.
/// Uses an [ExpansionTile] to display the [name] and [pzn] of the medicament.
/// After opening the tile, you get access to the package leaflet, order and
/// remove entry buttons.

class MedList {
  /// Stores the tap position for the [GestureDetector] to recognize swipes.
  /// Requires to be public by definition.
  static Offset tapPosition;

  /// Visualizes a whole [List<Med>]. Passes optional parameters, such as whether
  /// the item is [removable], and callback functions [onSwipe] for the swipe gesture
  /// and [onButtonDelete] for the pressed delete button.
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

  /// Visualizes a single medicament [item]. Implements the callback for the
  /// swipe gesture [onSwipe].
  static Widget buildItem(BuildContext context, int index, Med item,
      [bool removable = false,
      Function(Med) onSwipe,
      Function(Med) onButtonDelete]) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,

        /// Represent the arrow color when the expansion tile is opened.
        accentColor: Colors.black,
      ),
      child: (removable)
          ? GestureDetector(
              onTapDown: (details) {
                tapPosition = details.globalPosition;
              },
              child: Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  if (onSwipe != null) {
                    onSwipe(item);
                  }
                },
                child: _buildItemCore(context, item, removable, onButtonDelete),
              ),
            )
          : _buildItemCore(context, item, removable, onButtonDelete),
    );
  }

  /// Core visualization of a medicament [item]. Implements the callback for the
  /// pressed delete button [onButtonDelete].
  static Widget _buildItemCore(BuildContext context, Med item, bool removable,
      Function(Med) onButtonDelete) {
    return ExpansionTile(
      key: new PageStorageKey<Key>(item.key),

      /// Background color of an opened expansion tile.
      backgroundColor: Color(0xffFFD4D4),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              /// Do not draw a history icon, if [pzn] is unknown ([item.name.length <= 0]).
              if (item.isHistory && item.name.length > 0)
                Icon(
                  Icons.history,
                  size: 25,
                ),
              Padding(
                padding: EdgeInsets.only(
                    left: (item.isHistory && item.name.length > 0) ? 30 : 0),
                child: Text(
                  /// Default text on unknown [pzn] number.
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
        /// Buttons that will show on an opened expansion tile.
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

        /// Shows a delete button if [removable] is [true].
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

        /// Button that will pop on an item with an unknown [pzn].
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
