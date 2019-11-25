import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:maph_group3/util/helper.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/product_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

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
  String shoppingInfo;
  bool shoppingInfoLoaded = false;

  List<ShopListItem> itemList;

  @override
  void initState() {
    super.initState();
    //getSearchResults("Ibuprofen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bestellen'),
      ),
      body: Column(
        children: <Widget>[
          buildLocalSearchButton(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: buildListView("Ibuprofen"),
            )
          ),
        ],
      )
    );
  }

  Widget buildListView(String searchKey) {
    return FutureBuilder<List<ShopListItem>>(
      future: getShopData(searchKey),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        return GestureDetector(
          onTap: orderMed,
          child: ListView(
            children: snapshot.data.map((item) =>
                Card(
                    child: ListTile(
                      leading: Image.network(item.image),
                      title: Text(item.name),
                      subtitle: Text(item.description),
                      trailing: Container(
                        child: Text(item.price),
                      ),
                      isThreeLine: true,
                    )
                )
               ).toList(),
            ),
          );
        }
    );
  }

  Widget buildLocalSearchButton() {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.black)
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

  Widget buildHtml() {
    return ListView(
      children: <Widget>[
          Html(
            data: shoppingInfo,
            padding: EdgeInsets.all(10.0),
            useRichText: false,
            onLinkTap: (url) { launch("https://www.medpex.de" + url);},
            customRender: (node, children) {
              if (node is dom.Element) {
                if (node.className == "product-list-entry") {
                  return
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => {
                            Navigator.push(context,
                              NoAnimationMaterialPageRoute(
                                  builder: (context) => ProductDetails(url: "test")
                              ),
                            ),
                          },//orderMed,
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              border: Border.all(width: 1),
                            ),
                            child: DefaultTextStyle(
                              child: Column(
                                children: children,
                              ),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                        ),
                      ]
                  );
                }
                return null;
              }
              return null;
            },
          ),
        ],
    );
  }

  Future<List<ShopListItem>> getShopData(String name) async {
    String url = "https://www.medpex.de/search.do?q=" + name;
    String html = await Helper.fetchHTML(url);
    return ShopListParser.parseHtmlToShopListItem(html);
  }

  /*Future getSearchResults(String medName) async {
    //String url = "https://www.google.com/search?q=" + medName + "&sxsrf=ACYBGNRP9tSbBnmwBlVO_M-uS_gFZ2Sp6Q:1574093322364&source=lnms&tbm=shop&sa=X&ved=0ahUKEwj6ncrKkvTlAhVLKVAKHWi4BKwQ_AUIEigB&biw=740&bih=979";
    String url = "https://www.medpex.de/search.do?q=" + medName;
    String html = await fetchHTML(url);

    /*if(html != null) {
      shoppingInfo = Helper.parseMid(html, '<div id="product-list">', '<div class="pagenav">');
      shoppingInfo = '<div id="product-list">' + shoppingInfo + "</div>";
      // replace unsupported and unnecessary tags
      shoppingInfo = shoppingInfo.replaceAll(new RegExp("<input.*>"), "");
      shoppingInfo = shoppingInfo.replaceAll(new RegExp("<form.*>"), "");
      shoppingInfo = shoppingInfo.replaceAll(new RegExp("<option.*</option>"), "");
      shoppingInfo = shoppingInfo.replaceAll(new RegExp("<div class=\"caption\".*</div>"), "");
      shoppingInfo = shoppingInfo.replaceAll(new RegExp("<div class=\"rating\".*</div>"), "");
    } else {
      // display: couldnt load shopping data
    }*/

    itemList = ShopListParser.parseHtmlToShopListItem(html);

    setState(() {
      shoppingInfoLoaded = true;
    });
  }*/

  void orderMed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Bestellen"),
          content: new Text("Medikament jetzt bestellen?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Abbrechen"),
              onPressed: () {
                Navigator.of(context).pop();
             },
            ),
            new FlatButton(
              child: new Text("Fortfahren"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
