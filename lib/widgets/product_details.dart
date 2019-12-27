import 'package:flutter/material.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/order_summary.dart';

import '../data/globals.dart' as globals;

class ProductDetails extends StatefulWidget {
  final String searchKey;

  ProductDetails({Key key, @required this.searchKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailsState();
  }
}

class _ProductDetailsState extends State<ProductDetails> {
  // search key and shop item
  String medSearchKey;
  ShopItem localShopItem;

  final textEditController = TextEditingController();

  @override
  void initState() {
    super.initState();

    medSearchKey = widget.searchKey;
    if(globals.items.containsKey(medSearchKey)) {
      localShopItem = globals.items[medSearchKey];
    }
  }

  @override
  void dispose(){
    textEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produktinfo"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildImageContainer(),
            buildMainView(),
            buildOrderCompleteContainer(),
          ],
        ),
      ),
    );
  }

  Widget buildImageContainer() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width,
        decoration: new BoxDecoration (
          borderRadius: new BorderRadius.horizontal(),
          border: Border.all(color: Colors.black54),
        ),
        padding: EdgeInsets.all(15),
        child: Image.asset(localShopItem.image),
      ),
    );
  }

  Widget buildMainView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Text(localShopItem.name, style: TextStyle(fontSize: 30),),
        ),
        Container(
          child: Column(
            children: <Widget>[
              Divider(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                child: Text("Beschreibung", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(localShopItem.desc),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                child: Text("Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Table(
                    columnWidths: {
                      0: FixedColumnWidth(MediaQuery.of(context).size.width*0.3),
                      1: FixedColumnWidth(MediaQuery.of(context).size.width*0.7),
                    },
                    children: [
                      TableRow(
                        children: [
                          Text("Hersteller", style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(localShopItem.brand),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("\nDosierung", style: TextStyle(fontWeight: FontWeight.bold),),
                          Text("\n" + localShopItem.dosage),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("\nPZN", style: TextStyle(fontWeight: FontWeight.bold),),
                          Text("\n" + localShopItem.pzn),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text("\nRezeptfrei", style: TextStyle(fontWeight: FontWeight.bold),),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: localShopItem.onlyAvailableOnPrescription? Icon(Icons.block, color: Colors.red,) : Icon(Icons.check_circle_outline, color: Colors.green,),
                          ),
                        ],
                      ),
                    ]
                ),
              ),
              Divider(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
        ),
      ],
    );
  }

  Widget buildOrderCompleteContainer() {
    return Row(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(20),),
        new Flexible(
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: textEditController,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2)
                  )
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.all(10),),
        new Flexible(
          child: RaisedButton(
            onPressed: validateInputAndProceed,
            child: Text("Jetzt bestellen", style: TextStyle(color: Colors.green),),
          ),
        ),
        Padding(padding: EdgeInsets.all(20),),
      ],
    );
  }

  void validateInputAndProceed() {
    if(textEditController.text.isNotEmpty) {
      this.localShopItem.orderQuantity = int.parse(textEditController.text);
      Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => OrderSummary(item: this.localShopItem)));
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Bitte Anzahl eingeben"),
            content: Text("Bitte Anzahl der zu bestellenden Medikamenten eingeben."),
          );
        }
      );
    }
  }
}
