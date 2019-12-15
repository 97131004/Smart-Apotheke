import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/personaldata.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/personal.dart';

import 'package:location/location.dart' as LocationManager;

class OrderSummary extends StatefulWidget {
  final ShopItem item;

  OrderSummary({Key key, @required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OrderSummaryState();
  }
}

class _OrderSummaryState extends State<OrderSummary> {

  bool agbIsChecked = false;
  bool dataIsComplete = false;
  bool visibilityShippingCosts = false;
  bool deliverToApo = false;

  @override
  initState() {
    super.initState();
    _checkData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bestellübersicht"),
      ),
      body: Visibility(
        visible: dataIsComplete,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(5),),
              _buildProductOverview(),
              Padding(padding: EdgeInsets.all(5),),
              _buildPaymentOptions(),
              Padding(padding: EdgeInsets.all(5),),
              _buildShippingOptions(),
              Padding(padding: EdgeInsets.all(5),),
              _buildConfirmationContainer(),
              Padding(padding: EdgeInsets.all(5),),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductOverview() {
    double shippingCosts = deliverToApo? 0 : 2.99;
    double grossPrice = ((widget.item.priceInt * widget.item.orderQuantity)/100) + shippingCosts;
    double tax = grossPrice * 0.19;
    double netPrice = grossPrice - tax;
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(width: 1.0, color: Colors.black54),
        ),
        columnWidths: {
          0: FixedColumnWidth(MediaQuery.of(context).size.width*0.65),
          1: FixedColumnWidth(MediaQuery.of(context).size.width*0.10),
          2: FixedColumnWidth(MediaQuery.of(context).size.width*0.25),
        },
        children: [
          TableRow(
            children: [
              Text("\nProdukt", style: TextStyle(fontWeight: FontWeight.bold),),
              Center(child: Text("\nAnzahl", style: TextStyle(fontWeight: FontWeight.bold),),),
              Center(child: Text("\nGesamtpreis", style: TextStyle(fontWeight: FontWeight.bold),),),
            ],
          ),
          TableRow(
            children: [
              Container(
                child: Row(
                  children: <Widget>[
                    Image.asset('assets/dummy_med.png', height: 50, width: 50,),
                    Padding(padding: EdgeInsets.all(3),),
                    Flexible(child: Text("\n" + widget.item.name + "\n" + widget.item.dosage + "\n", textWidthBasis: TextWidthBasis.parent,),),
                  ],
                ),
              ),
              Center(child: Text("\n" + widget.item.orderQuantity.toString()),),
              Center(child: Text("\n" + netPrice.toStringAsFixed(2) + " €\n"),),
            ],
          ),
          TableRow(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("\nSteuer"),
                  Text("\nVersandkosten\n"),
              ],),
              Column(children: <Widget>[
                Text(""),
                Text(""),
              ],),
              Column(children: <Widget>[
                Text("\n" + tax.toStringAsFixed(2) + " €"),
                Text("\n" + shippingCosts.toStringAsFixed(2) + " €"),
              ],),
            ],
          ),
          TableRow(
            children: [
              Text("\nGesamtsumme:", style: TextStyle(fontWeight: FontWeight.bold),),
              Center(child: Text("")),
              Center(child: Text("\n" + grossPrice.toStringAsFixed(2) + " €"),),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    String ls = 'Lastschrift';
    String pp = 'PayPal';
    String nn = 'Nachname / Bar vor Ort';
    String temp = ls;
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Column(
        children: <Widget>[
          Text("Zahlungsmöglichkeiten"),
          RadioButtonGroup(
              labels: <String>[
                ls,
                pp,
                nn,
              ],
              onSelected: (String selected) => {
                temp = selected
              }
          )
        ],
      ),
    );
  }

  Widget _buildShippingOptions() {
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Column(
        children: <Widget>[
          Text('Liefermöglichkeiten:'),
          RadioButtonGroup(
              labels: <String>[
                'Nach Hause liefern lassen ( + 2.99 € )',
                'An Apotheke liefern lassen',
              ],
              onSelected: (String selected) => {
                setState(() => {
                  if(selected == 'An Apotheke liefern lassen') {
                    deliverToApo = true
                  } else {
                    deliverToApo = false
                  }
                })
              }
          ),
          _buildGooglemapsContainer(),
        ],
      ),
    );
  }

  Widget _buildBillingAdress() {
    return new Container();
  }

  Widget _buildGooglemapsContainer() {
    return Visibility(
      visible: deliverToApo,
      child: Container(
        decoration: _getContainerDecoration(1, 0),
        height: MediaQuery.of(context).size.height/4,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          initialCameraPosition: new CameraPosition(target: LatLng(52.45654549, 13.52600992)),
          mapType: MapType.normal,
          //markers: Set<Marker>.of(markers.values),
        ),
      ),
    );
  }

  Widget _buildConfirmationContainer() {
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Column(
        children: <Widget>[
          Text("Confirmation"),
          CheckboxGroup(
            labels: <String>[
              'AGBs zustimmen',
              'Ich bin damit einverstanden, dass...',
            ],
            onSelected: (List<String> checked) => {
              if(checked.length == 2) {
                agbIsChecked = true
              }
            }
          ),
          RaisedButton(
            onPressed: goToOrderConfirmed,
            child: Text("Zahlungspflichtig bestellen", style: TextStyle(color: Colors.blue),),
          ),
        ],
      ),
    );
  }

  BoxDecoration _getContainerDecoration(double borderWidth, double circular) {
    return BoxDecoration(
      border: Border.all(
        color: Colors.black54,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(circular),
    );
  }

  _checkData() {
    if(!PersonalData.isUserDataComplete()) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await _buildAlertDialog(context, 'Daten unvollständig', 'Ihre persönlichen Daten sind nicht vollständig. Bitte überprüfen und ergänzen.');
        Navigator.push(
          context,
          NoAnimationMaterialPageRoute(
              builder: (context) => Personal()),
        );
      });
    }
    // TODO
    dataIsComplete = true;
  }

  Future<void> _buildAlertDialog(BuildContext context, String caption, String text) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(caption),
          content: Text(text),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<LatLng> getCurrentLocation() async {
    final location = LocationManager.Location();
    try {
      var currentloc = await location.getLocation();
      final lat = currentloc.latitude;
      final lng = currentloc.longitude;
      return LatLng(lat, lng);
    } catch (e) {
      return LatLng(0, 0);
    }
  }

  void goToOrderConfirmed() {
    if(agbIsChecked) {
      // go to confirmed page
      print("confirmed");
    } else {
      // agb not checked
      _buildAlertDialog(context, "AGBs bestätigen", 'Bitte AGBs bestätigen um fortzufahren');
    }
  }
}
