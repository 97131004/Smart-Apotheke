import 'package:flutter/material.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/order_summary.dart';

import '../data/globals.dart' as globals;

/// The class gives a product overview with all details regarding the medicament.
/// It has an input field, where the user can specify the amount of the product
/// he wants to order and sees the price for his order.
class ProductDetails extends StatefulWidget {
  final String searchKey;

  ProductDetails({Key key, @required this.searchKey}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductDetailsState();
  }
}

class _ProductDetailsState extends State<ProductDetails> {
  /// search key and local shop item
  String _medSearchKey;
  ShopItem _localShopItem;

  int _quantity = 1;

  final TextEditingController _textEditController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// get the local shop item by search key
    _medSearchKey = widget.searchKey;
    if(globals.items.containsKey(_medSearchKey)) {
      _localShopItem = globals.items[_medSearchKey];
    }
  }

  @override
  void dispose(){
    _textEditController.dispose();
    super.dispose();
  }

  /// Build the main view of the product details page.
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

  /// Build the image container for the product.
  Widget buildImageContainer() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width,
        decoration: new BoxDecoration (
          borderRadius: new BorderRadius.horizontal(),
          border: Border.all(color: Theme.of(context).splashColor),
        ),
        padding: EdgeInsets.all(15),
        child: Image.asset(_localShopItem.image),
      ),
    );
  }

  /// Build the main part where details of the medicament are displayed.
  Widget buildMainView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Center(child: Text(_localShopItem.name, style: TextStyle(fontSize: 30),),),
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
                child: Text(_localShopItem.desc),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.centerLeft,
                child: Text("Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              ),
              _buildDetailsContainer(),
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

  Widget _buildDetailsContainer() {
    return Container(
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
                Text(_localShopItem.brand),
              ],
            ),
            TableRow(
              children: [
                Text("\nDosierung", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("\n" + _localShopItem.dosage),
              ],
            ),
            TableRow(
              children: [
                Text("\nPZN", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("\n" + _localShopItem.pzn),
              ],
            ),
            TableRow(
              children: [
                Text("\nRezeptfrei", style: TextStyle(fontWeight: FontWeight.bold),),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: _localShopItem.onlyAvailableOnPrescription?
                  Icon(Icons.block, color: Colors.red,) :
                  Icon(Icons.check_circle_outline, color: Colors.green,),
                ),
              ],
            ),
          ]
      ),
    );
  }

  /// Build the complete order container.
  Widget buildOrderCompleteContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildPricingContainer(),
        _buildInputField(),
        new Flexible(
          child: RaisedButton(
            onPressed: validateInputAndProceed,
            child: Text("Bestellen", style: TextStyle(color: Theme.of(context).backgroundColor),),
          ),
        ),
      ],
    );
  }

  /// Build the price input field.
  Widget _buildInputField() {
    return new Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width/6,
        //padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: TextField(
          keyboardType: TextInputType.number,
          controller: _textEditController,
          decoration: new InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).splashColor)
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)
              )
          ),
          onChanged: (String value) => {
            setState(() => {
              _quantity = int.parse(value)
            }),
          },
        ),
      ),
    );
  }

  /// Build container with pricing information.
  Widget _buildPricingContainer() {
    double price = ((_localShopItem.priceInt * _quantity) / 100);
    return new Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text('Gesamtpreis:', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              Text(price.toString() + ' €', style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text('Stückpreis:'),
              ),
              Text(_localShopItem.price),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text('UVP*:'),
              ),
              Text(_localShopItem.crossedOutPrice, style: TextStyle(color: Theme.of(context).errorColor, decoration: TextDecoration.lineThrough,),),
            ],
          ),
        ],
      ),
    );
  }

  /// Validate the input of the text field.
  /// Shows alert when input field is left empty.
  void validateInputAndProceed() {
    if(_textEditController.text.isNotEmpty) {
      this._localShopItem.orderQuantity = int.parse(_textEditController.text);
      Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => OrderSummary(item: this._localShopItem)));
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
