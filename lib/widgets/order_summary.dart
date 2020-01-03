import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/personal_data.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/maps.dart';
import 'package:maph_group3/widgets/order_confirmation.dart';
import 'package:maph_group3/widgets/personal.dart';
import 'package:intl/intl.dart';

class OrderSummary extends StatefulWidget {
  final ShopItem item;

  OrderSummary({Key key, @required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OrderSummaryState();
  }
}

class _OrderSummaryState extends State<OrderSummary> {

  // google maps controller and markers
  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<String, PlacesSearchResult> foundPlaces = <String, PlacesSearchResult>{};

  bool agbIsChecked = false;
  bool dataIsComplete = false;
  bool visibilityShippingCosts = false;
  bool deliverToApo = false;

  bool markerIsTabbed = false;
  PlacesSearchResult currentMarker;
  bool isLoaded = false;
  String shippingAddress = '';

  String _pickedDelivered = 'Nach Hause liefern lassen ( + 2.99 € )';
  String _pickedPayment = 'Lastschrift';

  PlacesSearchResult _pickedApo;

  @override
  initState() {
    super.initState();
    _checkData();
    getShippingAddress();
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
              Padding(
                padding: EdgeInsets.all(5),
              ),
              _buildProductOverview(),
              Padding(
                padding: EdgeInsets.all(5),
              ),
              _buildPaymentOptions(),
              Padding(
                padding: EdgeInsets.all(5),
              ),
              _buildShippingOptions(),
              Padding(
                padding: EdgeInsets.all(5),
              ),
              _buildConfirmationContainer(),
              Padding(
                padding: EdgeInsets.all(5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductOverview() {
    double shippingCosts = deliverToApo ? 0 : 2.99;
    double grossPrice =
        ((widget.item.priceInt * widget.item.orderQuantity) / 100) +
            shippingCosts;
    double tax = grossPrice * 0.10;
    double netPrice = grossPrice - tax;
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(width: 1.0, color: Colors.black54),
        ),
        columnWidths: {
          0: FixedColumnWidth(MediaQuery.of(context).size.width * 0.65),
          1: FixedColumnWidth(MediaQuery.of(context).size.width * 0.10),
          2: FixedColumnWidth(MediaQuery.of(context).size.width * 0.25),
        },
        children: [
          TableRow(
            children: [
              Text(
                "\nProdukt",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Center(
                child: Text(
                  "\nAnzahl",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  "\nGesamtpreis",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              Container(
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      'assets/dummy_med.png',
                      height: 50,
                      width: 50,
                    ),
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                    Flexible(
                      child: Text(
                        "\n" +
                            widget.item.name +
                            "\n" +
                            widget.item.dosage +
                            "\n",
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Text("\n" + widget.item.orderQuantity.toString()),
              ),
              Center(
                child: Text("\n" + netPrice.toStringAsFixed(2) + " €\n"),
              ),
            ],
          ),
          TableRow(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("\nMehrwertsteuer 10%"),
                  Text("\nVersandkosten\n"),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(""),
                  Text(""),
                ],
              ),
              Column(
                children: <Widget>[
                  Text("\n" + tax.toStringAsFixed(2) + " €"),
                  Text("\n" + shippingCosts.toStringAsFixed(2) + " €"),
                ],
              ),
            ],
          ),
          TableRow(
            children: [
              Text(
                "\nGesamtsumme:\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Center(child: Text("")),
              Center(
                child: Text("\n" + grossPrice.toStringAsFixed(2) + " €"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Column(
        children: <Widget>[
          Text("Zahlungsmöglichkeiten"),
          RadioButtonGroup(
              activeColor: Colors.green,
              labels: <String>[
                'Lastschrift',
                'PayPal',
                'Nachname / Bar vor Ort',
              ],
              picked: _pickedPayment,
              onSelected: (String selected) => {
                    setState(() => {_pickedPayment = selected})
                  })
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
              activeColor: Colors.green,
              labels: <String>[
                'Nach Hause liefern lassen ( + 2.99 € )',
                'An Apotheke liefern lassen',
              ],
              picked: _pickedDelivered,
              onSelected: (String selected) => {
                    _pickedDelivered = selected,
                    if (_pickedApo == null) _findApo(selected),
                    setState(() => {
                          if (selected == 'An Apotheke liefern lassen')
                            {deliverToApo = true}
                          else
                            {deliverToApo = false}
                        })
                  }),
          _buildGooglemapsContainer(),
          _buildApoAddressContainer(),
          _buildBillingAdress(),
        ],
      ),
    );
  }

  _findApo(String selected) async {
    var result = await Navigator.push(
        context, NoAnimationMaterialPageRoute(builder: (context) => Maps()));
    if (result != null) {
      _pickedApo = result;
    }
  }

  Widget _buildBillingAdress() {
    String address =
        shippingAddress != '' ? shippingAddress : 'Lieferadresse fehlt!';
    if (!deliverToApo) {
      return Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          decoration: _getContainerDecoration(1, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Lieferadresse:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(address),
                ],
              ),
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Lieferadresse bearbeiten',
                onPressed: () {
                  Navigator.push(
                      context,
                      NoAnimationMaterialPageRoute(
                          builder: (context) => Personal()));
                },
              ),
            ],
          ));
    } else {
      return Container();
    }
  }

  Widget _buildGooglemapsContainer() {
    var temp = new DateTime.now();
    var date = new DateTime(temp.year,temp.month, temp.day, temp.hour + 2, 30);
    var formatter = new DateFormat('HH:mm - dd.MM.yyyy');
    String formattedDate = formatter.format(date);

    if (_pickedApo != null) {
      return Visibility(
        visible: deliverToApo,
        child: Column(
          children: <Widget>[
            Container(
                decoration: _getContainerDecoration(1, 0),
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
                      initialCameraPosition: new CameraPosition(
                          target: LatLng(52.45654549, 13.52600992)),
                      mapType: MapType.normal,
                      onMapCreated: _onMapCreated,
                      markers: Set<Marker>.of(markers.values),
                      //onTap: MapsHelper.openMap(currentMarker.geometry.location.lat, currentMarker.geometry.location.lng),
                    ),
                    Positioned(
                        right: 10.0,
                        top: 10.0,
                        child: Opacity(
                          opacity: 0.6,
                          child: FloatingActionButton.extended(
                            icon: Icon(Icons.fullscreen),
                            label: Text('Auswahl'),
                            backgroundColor: Colors.green,
                            onPressed: () {
                              Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Maps()));
                            },
                          ),
                        ))
                  ],
                )),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.location_on),
                  Column(
                    children: <Widget>[
                      Text(_pickedApo.name, style: TextStyle(fontWeight: FontWeight.bold),),
                      Text(_pickedApo.formattedAddress),
                      Text('Früheste Abholzeit: ' + formattedDate, style: TextStyle(color: Colors.red),),
                    ],
                  ),
                ],
              )
            )
          ],
        ),
      );
    } else {
      if (deliverToApo) {
        return Container(
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () => {
              Navigator.push(context,
                  NoAnimationMaterialPageRoute(builder: (context) => Maps())),
            },
          ),
        );
      } else {
        return Container();
      }
    }
  }

  _buildApoAddressContainer() {
    if (markerIsTabbed) {
      return Container(
          child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Flexible(
                child: Text(currentMarker.name),
              ),
              Flexible(child: Text(currentMarker.formattedAddress)),
            ],
          ),
        ],
      ));
    } else {
      return Container(
          child: Padding(
        padding: EdgeInsets.all(5),
      ));
    }
  }

  Widget _buildConfirmationContainer() {
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Column(
        children: <Widget>[
          Text("Geschäftsbedingungen und Benachrichtigungen"),
          CheckboxGroup(
              checkColor: Colors.white,
              activeColor: Colors.green,
              labels: <String>[
                'AGBs zustimmen',
                'Ich bin damit einverstanden, dass...',
              ],
              onSelected: (List<String> checked) => {
                    checked.forEach((it) => {
                      if(it == 'AGBs zustimmen') { agbIsChecked = true }
                      else { agbIsChecked = false }
                    })
                  }),
          RaisedButton(
            onPressed: goToOrderConfirmed,
            child: Text(
              "Zahlungspflichtig bestellen",
              style: TextStyle(color: Colors.green),
            ),
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

  _checkData() async {
    if (!(await PersonalData.isUserDataComplete())) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await _buildAlertDialog(context, 'Daten unvollständig',
            'Ihre persönlichen Daten sind nicht vollständig. Bitte überprüfen und ergänzen.');
        Navigator.push(
          context,
          NoAnimationMaterialPageRoute(builder: (context) => Personal()),
        );
      });
    }
    dataIsComplete = true;
  }

  Future<void> _buildAlertDialog(
      BuildContext context, String caption, String text) {
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

  Future _onMapCreated(GoogleMapController mapsController) async {
    controller = mapsController;

    if (_pickedApo != null) {
      final loc = LatLng(
          _pickedApo.geometry.location.lat, _pickedApo.geometry.location.lng);
      // final loc = Location(_pickedApo.geometry.location.lat, _pickedApo.geometry.location.lng);

      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: loc,
        zoom: 14.0,
      )));

      setState(() {
        addMarker(_pickedApo.id, loc, place: _pickedApo);
        isLoaded = true;
      });
    }
  }

  void addMarker(var id, LatLng latlng,
      {PlacesSearchResult place, double colorDescriptor}) {
    final MarkerId markerId = MarkerId(id);
    Marker marker;

    if (id == 'Mein Standort') {
      marker = Marker(
          markerId: markerId,
          position: latlng,
          infoWindow: InfoWindow(title: id, snippet: ''));
    } else {
      String oh = '';
      if (place.openingHours != null && place.openingHours.openNow != null) {
        oh = place.openingHours.openNow
            ? 'Jetzt geöffnet'
            : 'Momentan geschlossen';
      }
      if (colorDescriptor == null) {
        colorDescriptor = BitmapDescriptor.hueGreen;
      }
      marker = Marker(
        markerId: markerId,
        position: latlng,
        infoWindow: InfoWindow(title: place.name, snippet: oh),
        icon: BitmapDescriptor.defaultMarkerWithHue(colorDescriptor),
        onTap: () {
          _onMarkerTapped(id);
        },
      );
    }

    if (marker != null) {
      setState(() {
        // adding a new marker to map
        if (!markers.containsKey(markerId)) {
          markers[markerId] = marker;
        }
      });
    }
  }

  _onMarkerTapped(id) {
    setState(() {
      currentMarker = foundPlaces[id];
      markerIsTabbed = true;
    });
  }

  void goToOrderConfirmed() {
    if (agbIsChecked) {
      // go to confirmed page
      Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => OrderConfirmation()));
    } else {
      // agb not checked
      _buildAlertDialog(
          context, "AGBs bestätigen", 'Bitte AGBs bestätigen um fortzufahren');
    }
  }

  Future<String> getShippingAddress() async {
    List<String> adresse = await PersonalData.getadresse();
    if (adresse != null)
      setState(() {
        shippingAddress = adresse[0] +
            " " +
            adresse[1] +
            "\n" +
            adresse[2] +
            "\n" +
            adresse[3] +
            " " +
            adresse[4];
      });
  }
}
