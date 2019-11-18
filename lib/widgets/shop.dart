import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:maph_group3/util/helper.dart';
import 'package:maph_group3/util/load_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;

import '../data/med.dart';

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

  @override
  void initState() {
    super.initState();

    getSearchResults("Ibuprofen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bestellen'),
      ),
      body: shoppingInfoLoaded
          ? buildHtml()
          : LoadBar.build(),
    );
  }

  Widget buildHtml() {
    return ListView(
      children: <Widget>[
          Html(
            data: shoppingInfo,
            padding: EdgeInsets.all(8.0),
            onLinkTap: (url) { launch("https://www.medpex.de" + url);},
          ),
        ],
    );
  }

  Future getSearchResults(String medName) async {
    //String url = "https://www.google.com/search?q=" + medName + "&sxsrf=ACYBGNRP9tSbBnmwBlVO_M-uS_gFZ2Sp6Q:1574093322364&source=lnms&tbm=shop&sa=X&ved=0ahUKEwj6ncrKkvTlAhVLKVAKHWi4BKwQ_AUIEigB&biw=740&bih=979";
    String url = "https://www.medpex.de/search.do?q=" + medName;
    String html = await fetchHTML(url);

    if(html != null) {
      shoppingInfo = Helper.parseMid(html, '<div id="product-list">', '<div class="pagenav">');
      shoppingInfo = '<div id="product-list">' + shoppingInfo;
      // replace unsupported tags
      shoppingInfo = shoppingInfo.replaceAll(new RegExp("<input.*>"), "");
      shoppingInfo = shoppingInfo.replaceAll(new RegExp("<form.*>"), "");
      shoppingInfo = shoppingInfo.replaceAll(new RegExp("<option.*</option>"), "");
    } else {
      // display: couldnt load shopping data
    }

    setState(() {
      shoppingInfoLoaded = true;
    });
  }

  Future<String> fetchHTML(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200)
      return response.body;
    else return null;
  }
}
