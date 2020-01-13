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

class Shop extends StatefulWidget {
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

  String shoppingInfo;
  bool shoppingInfoLoaded = false;
  String sorting = cPriceSort;

  String medSearchKey = '';
  ShopItem localShopItem;

  Future<List<ShopItem>> itemList;

  @override
  void initState() {
    Helper.hasInternet().then((internet) {
      if (internet == null || !internet) {
        NoInternetAlert.show(context);
      }
    });

    if(widget.med != null) {
      medSearchKey = widget.med.name;
      if(globals.items.containsKey(widget.med.pzn)) {
        localShopItem = globals.items[widget.med.pzn];
        medSearchKey = localShopItem.searchKey;
      }
    }

    getShopData(medSearchKey);

    super.initState();
  }

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
              Padding(padding: EdgeInsets.all(10),),
              Flexible(child: Text('Ergebnisliste für ' + medSearchKey),),
              Spacer(),
              _buildDropDownMenu(),
              Padding(padding: EdgeInsets.all(10),),
            ],
          ),
          Visibility(
            visible: (localShopItem != null),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: buildCard(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: buildListView(medSearchKey),
            )
          ),
        ],
      )
    );
  }

  Widget _buildDropDownMenu() {
    return DropdownButton<String>(
      value: sorting,
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
          sorting = newValue;
        });
      },
      items: <String>[cPriceSort, cPriceASC, cPriceDSC].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget buildCard() {
    if(localShopItem != null) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
            decoration: new BoxDecoration (
              borderRadius: new BorderRadius.circular(5),
              border: Border.all(color: Theme.of(context).splashColor),
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Theme.of(context).primaryColor, Theme.of(context).backgroundColor]
              ),
            ),
            child: buildListTileOwnProd()
        ),
      );
    } else {
      return Container();
    }

  }

  ListTile buildListTileOwnProd() {
    return ListTile(
      contentPadding: EdgeInsets.all(10),
      onTap: () => { Navigator.push(
         context,
         NoAnimationMaterialPageRoute(builder: (context) => ProductDetails(searchKey: this.localShopItem.pzn))),
      },
      leading: Image.asset('assets/dummy_med.png'),
      title: Text(localShopItem.name),
      subtitle: Text(localShopItem.dosage + '\n' + localShopItem.brand + '\n\n' + localShopItem.merchant, style: TextStyle(fontSize: 12)),
      trailing: Column(
        children: <Widget>[
          Flexible(child: Text('In-App bestellen!', style: TextStyle(color: Theme.of(context).errorColor),),),
          Column(
            children: <Widget>[
              Text(localShopItem.price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(localShopItem.crossedOutPrice, style: TextStyle(color: Theme.of(context).errorColor, decoration: TextDecoration.lineThrough)),
              Text(localShopItem.pricePerUnit),
            ]
          ),
        ],
      )
    );
  }

  Widget buildListView(String searchKey) {
    return FutureBuilder<List<ShopItem>>(
      future: itemList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: LoadBar.build());
        }

        snapshot.data.sort((a,b) {
          if(sorting == cPriceASC) {
            return a.compareTo(b);
          }
          if(sorting == cPriceDSC) {
            return b.compareTo(a);
          }
          return 0;
        });

        return ListView(
          children: snapshot.data.map((item) =>
            Card(
              child: ListTile(
                onTap: () async {
                  await launchUrl(item);
                },
                leading: item.image != null ? Image.network(item.image) : Image.asset('assets/dummy_med.png'),
                title: Text(item.name),
                subtitle: Text((item.dosage ?? '') + "\n" + (item.brand ?? '') + "\n\nAnbieter: " + (item.merchant ?? ''), style: TextStyle(fontSize: 12)),
                trailing: Container(
                child: Column(
                  children: <Widget>[
                    Text(item.price ?? '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    if(item.crossedOutPrice != null) Text(item.crossedOutPrice, style: TextStyle(color: Theme.of(context).errorColor, decoration: TextDecoration.lineThrough),),
                    Text(item.pricePerUnit ?? ''),
                  ],
                )
              ),
              isThreeLine: true,
            )
          )
        ).toList(),
      );
    });
  }

  Widget buildLocalSearchButton() {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              side: BorderSide(color: Theme.of(context).splashColor)
          ),
          onPressed: () {
            Navigator.push(
              context,
              NoAnimationMaterialPageRoute(builder: (context) => Maps()),
            );},
          child: Row(
            children: <Widget>[
              Icon(Icons.search),
              Center(
                child: Text('Nach Apotheken in der Nähe suchen',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20)
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  Future<void> getShopData(String name) async {
    var dmList = await getDocMorrisList(name);
    var mpList = await getMedPexList(name);
    setState(() {
      itemList = ShopListParser.mergeLists(dmList, mpList);
    });
  }

  Future<List<ShopItem>> getDocMorrisList(String name) async {
    String urlDocMorris = 'https://www.docmorris.de/search?query=' + name;
    String htmlDocMorris = await Helper.fetchHTML(urlDocMorris);
    var listDocMorris = await ShopListParser.parseHtmlToShopListItemDocMorris(htmlDocMorris);
    return listDocMorris;
  }

  Future<List<ShopItem>> getMedPexList(String name) async {
    String urlMedpex = 'https://www.medpex.de/search.do?q=' + name;
    String htmlMedpex = await Helper.fetchHTML(urlMedpex);
    var listMedPex = await ShopListParser.parseHtmlToShopListItemMedpex(htmlMedpex);
    return listMedPex;
  }

  Future launchUrl(ShopItem item) async {
    String url;
    if(item.merchant == 'Medpex') {
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
