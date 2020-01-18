import 'package:flutter/material.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:maph_group3/util/load_bar.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/no_internet_alert.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/product_details.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/globals.dart' as globals;
import '../data/med.dart';
import 'maps.dart';

/// The class displays medicaments that can be ordered in-app or external on a
/// merchants website. In the current state of the app, the external shop
/// results are parsed from the vendors website due to pricing of the API access.
/// Current vendors are [DocMorris.com] and [MedPex.de]
/// Medicaments that can be ordered in-app, come from our database, that
/// currently implemented as a static array.
/// The medicament that comes from our database (so which we have in stock right
/// now) will always be displayed as the first entry of the list and is
/// highlighted.
/// Medicaments can be sorted by price, while medicaments from our database
/// will always be on top of the list.
class Shop extends StatefulWidget {
  /// pass the med object from previous page
  final Med med;

  Shop({Key key, @required this.med}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ShopState();
  }
}

class _ShopState extends State<Shop> {
  static final String cPriceASC = 'Preis aufsteigend';
  static final String cPriceDSC = 'Preis absteigend';
  static final String cPriceSort = 'Keine Sortierung';

  /// String holds current sorting direction
  String _sorting = cPriceSort;

  /// search key given by previous page
  String _medSearchKey = '';

  /// current local shop item that is from our db
  ShopItem _localShopItem;

  /// future list of medicaments from external vendors
  Future<List<ShopItem>> _itemList;

  @override
  void initState() {
    /// check if internet connection is available
    Helper.hasInternet().then((internet) {
      if (internet == null || !internet) {
        NoInternetAlert.show(context);
      }
    });

    /// set the search key for search on vendors website
    /// set our local medicament if it is available
    if (widget.med != null) {
      _medSearchKey = widget.med.name;
      if (globals.items.containsKey(widget.med.pzn)) {
        _localShopItem = globals.items[widget.med.pzn];
        _medSearchKey = _localShopItem.searchKey;
      }
    }

    /// gather shop data
    getShopData(_medSearchKey);

    super.initState();
  }

  /// Build the shopping list with internal and external items.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Bestellen'),
        ),
        body: Column(
          children: <Widget>[
            //buildLocalSearchButton(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                Flexible(
                  child: Text('Ergebnisliste für ' + _medSearchKey),
                ),
                Spacer(),
                _buildDropDownMenu(),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
              ],
            ),
            Visibility(
              visible: (_localShopItem != null),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                child: _buildCard(),
              ),
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: _buildListView(_medSearchKey),
            )),
          ],
        ));
  }

  /// Build the widget for the sorting drop down menu.
  Widget _buildDropDownMenu() {
    return DropdownButton<String>(
      value: _sorting,
      icon: Icon(Icons.sort),
      iconSize: 18,
      elevation: 16,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
      ),
      underline: Container(
        height: 2,
        color: Theme.of(context).primaryColor,
      ),
      onChanged: (String newValue) {
        setState(() {
          _sorting = newValue;
        });
      },
      items: <String>[cPriceSort, cPriceASC, cPriceDSC]
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  /// Build list item container for the local medicament if it is in db.
  Widget _buildCard() {
    if (_localShopItem != null) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.circular(5),
              //border: Border.all(color: Theme.of(context).splashColor),
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).accentColor,
                    Theme.of(context).backgroundColor
                  ]),
            ),
            child: buildListTileOwnProd()),
      );
    } else {
      return Container();
    }
  }

  /// Build list tile for own product.
  ListTile buildListTileOwnProd() {
    return ListTile(
        contentPadding: EdgeInsets.all(10),
        onTap: () => {
              Navigator.push(
                  context,
                  NoAnimationMaterialPageRoute(
                      builder: (context) =>
                          ProductDetails(searchKey: this._localShopItem.pzn))),
            },
        leading: Image.asset('assets/dummy_med.png'),
        title: Text(_localShopItem.name),
        subtitle: Text(
            _localShopItem.dosage +
                '\n' +
                _localShopItem.brand +
                '\n\n' +
                _localShopItem.merchant,
            style: TextStyle(fontSize: 12)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Text(
                'In-App bestellen!\n',
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            ),
            Text(_localShopItem.price,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            /*Text(localShopItem.crossedOutPrice,
                style: TextStyle(
                    color: Theme.of(context).errorColor,
                    decoration: TextDecoration.lineThrough)),*/
            Text(_localShopItem.pricePerUnit),
          ],
        ));
  }

  /// Build list view for vendors items.
  Widget _buildListView(String searchKey) {
    return FutureBuilder<List<ShopItem>>(
        future: _itemList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: LoadBar.build());
          }

          snapshot.data.sort((a, b) {
            if (_sorting == cPriceASC) {
              return a.compareTo(b);
            }
            if (_sorting == cPriceDSC) {
              return b.compareTo(a);
            }
            return 0;
          });

          return ListView(
            children: snapshot.data
                .map((item) => Card(
                        child: ListTile(
                      onTap: () async {
                        await launchUrl(item);
                      },
                      leading: item.image != null
                          ? Image.network(item.image)
                          : Image.asset('assets/dummy_med.png'),
                      title: Text(item.name),
                      subtitle: Text(
                          (item.dosage ?? '') +
                              "\n" +
                              (item.brand ?? '') +
                              "\n\nAnbieter: " +
                              (item.merchant ?? ''),
                          style: TextStyle(fontSize: 12)),
                      trailing: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                item.price ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              if (item.crossedOutPrice != null)
                                Text(
                                  item.crossedOutPrice,
                                  style: TextStyle(
                                    color: Theme.of(context).errorColor,
                                    decoration: TextDecoration.lineThrough),
                                ),
                              Text(item.pricePerUnit ?? ''),
                            ],
                          )
                      ),
                      isThreeLine: true,
                    )))
                .toList(),
          );
        });
  }

  /// Build search button for drug store search (this is currently not used).
  Widget buildLocalSearchButton() {
    return Center(
        child: Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            side: BorderSide(color: Theme.of(context).splashColor)),
        onPressed: () {
          Navigator.push(
            context,
            NoAnimationMaterialPageRoute(builder: (context) => Maps()),
          );
        },
        child: Row(
          children: <Widget>[
            Icon(Icons.search),
            Center(
              child: Text('Nach Apotheken in der Nähe suchen',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
            )
          ],
        ),
      ),
    ));
  }

  /// This method gathers the shop item data from the vendors.
  /// First it will parse the data for each shop and then merge lists.
  Future<void> getShopData(String name) async {
    var dmList = await getDocMorrisList(name);
    var mpList = await getMedPexList(name);
    if (this.mounted) {
      setState(() {
        _itemList = ShopListParser.mergeLists(dmList, mpList);
      });
    }
  }

  /// Send HTML-Request to vendors website and parse the dom model.
  /// Returns a list of ShopItem.
  /// Vendor: [DocMorris.com]
  Future<List<ShopItem>> getDocMorrisList(String name) async {
    String urlDocMorris = 'https://www.docmorris.de/search?query=' + name;
    String htmlDocMorris = await Helper.fetchHTML(urlDocMorris);
    var listDocMorris =
        await ShopListParser.parseHtmlToShopListItemDocMorris(htmlDocMorris);
    return listDocMorris;
  }

  /// Send HTML-Request to vendors website and parse the dom model.
  /// Returns a list of ShopItem.
  /// Vendor: [MedPex.de]
  Future<List<ShopItem>> getMedPexList(String name) async {
    String urlMedpex = 'https://www.medpex.de/search.do?q=' + name;
    String htmlMedpex = await Helper.fetchHTML(urlMedpex);
    var listMedPex =
        await ShopListParser.parseHtmlToShopListItemMedpex(htmlMedpex);
    return listMedPex;
  }

  /// Launches an in-app browser with the url to the requested medicament.
  /// Users can order the medicament from there.
  Future launchUrl(ShopItem item) async {
    String url;
    if (item.merchant == 'Medpex') {
      url = 'https://www.medpex.de/' + item.link;
    } else if (item.merchant == 'DocMorris') {
      url = 'https://www.docmorris.de/' + item.link;
    }
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true, enableJavaScript: true);
    } else {
      throw 'Could not launch $url';
    }
  }
}
