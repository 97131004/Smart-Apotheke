import 'package:flutter/material.dart';
import 'package:maph_group3/util/helper.dart';

class ProductDetails extends StatefulWidget {
  final String url;

  ProductDetails({Key key, @required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailsState();
  }
}

class _ProductDetailsState extends State<ProductDetails> {

  @override
  void initState() {
    super.initState();

    loadMedProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produktdaten'),
      ),
      body: Text('Produktdaten'),
    );
  }

  Future loadMedProductDetails() async {
    print(widget.url);
    //String url = "https://www.medpex.de/search.do?q=";
    String html = await Helper.fetchHTML(widget.url);
    print(html);
  }
}
