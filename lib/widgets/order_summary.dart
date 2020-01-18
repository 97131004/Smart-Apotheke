import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:maph_group3/data/med.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/personal_data.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/maps.dart';
import 'package:maph_group3/widgets/order_confirmation.dart';
import 'package:maph_group3/widgets/personal.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../util/med_get.dart';

/// The class gives an overview of the order the user is going to execute.
/// This page consists of different parts:
///   1. Product overview: Name, amount and price of medicament, including
///      tax and shipping (these values can change based on shipping options)
///   2. Payment options
///   3. Shipping options: Users can decide wether to ship the medicaments by
///      mail or to collect it at a selected drug store.
///   4. Confirmation of the order
class OrderSummary extends StatefulWidget {
  final ShopItem item;

  OrderSummary({Key key, @required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OrderSummaryState();
  }
}

class _OrderSummaryState extends State<OrderSummary> {
  /// google maps controller and markers
  GoogleMapController _controller;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<String, PlacesSearchResult> _foundPlaces = <String, PlacesSearchResult>{};

  PlacesSearchResult _currentMarker;
  PlacesSearchResult _pickedApo;

  /// used to load hidden / not yet loaded widgets depending on input
  bool _agbIsChecked = false;
  bool _dataIsComplete = false;
  bool _deliverToApo = false;
  bool _markerIsTabbed = false;

  String _shippingAddress = '';

  /// used to remember current state of radio group boxes
  String _pickedDelivered = 'Nach Hause liefern lassen ( + 2.99 € )';
  String _pickedPayment = 'Lastschrift';

  final TextEditingController _passwordController = new TextEditingController();

  @override
  initState() {
    super.initState();
    _checkData();
    getShippingAddress();
  }

  /// Build main view.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bestellübersicht'),
        ),
        body: Stack(
          children: <Widget>[
            Visibility(
              visible: !_dataIsComplete,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Visibility(
              visible: _dataIsComplete,
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
          ],
        )
      ),
    );
  }

  /// Build product overview as a table.
  Widget _buildProductOverview() {
    double shippingCosts = _deliverToApo ? 0 : 2.99;
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
          horizontalInside:
              BorderSide(width: 1.0, color: Theme.of(context).splashColor),
        ),
        columnWidths: {
          0: FlexColumnWidth(
              1.0), //FixedColumnWidth(MediaQuery.of(context).size.width * 0.65),
          1: FlexColumnWidth(0.2),
          2: FlexColumnWidth(0.3),
        },
        children: [
          _buildTableRowHeader(),
          _buildTableRowProduct(netPrice),
          _buildTableRowTaxAndShipping(tax, shippingCosts),
          _buildGrossPrice(grossPrice),
        ],
      ),
    );
  }

  /// Build table header.
  TableRow _buildTableRowHeader() {
    return TableRow(
      children: [
        Text(
          '\nProdukt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '\nAnzahl',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '\nGesamtpreis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Build product row.
  TableRow _buildTableRowProduct(double netPrice) {
    return TableRow(
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
                  '\n' + widget.item.name + '\n' + widget.item.dosage + '\n',
                  textWidthBasis: TextWidthBasis.parent,
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Text('\n' + widget.item.orderQuantity.toString()),
        ),
        Center(
          child: Text('\n' + netPrice.toStringAsFixed(2) + ' €\n'),
        ),
      ],
    );
  }

  /// Build shipping / tax  row.
  TableRow _buildTableRowTaxAndShipping(double tax, double shippingCosts) {
    return TableRow(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('\nMehrwertsteuer 10%'),
            Text('\nVersandkosten\n'),
          ],
        ),
        Column(
          children: <Widget>[
            Text(''),
            Text(''),
          ],
        ),
        Column(
          children: <Widget>[
            Text('\n' + tax.toStringAsFixed(2) + ' €'),
            Text('\n' + shippingCosts.toStringAsFixed(2) + ' €'),
          ],
        ),
      ],
    );
  }

  /// Build gross price row.
  TableRow _buildGrossPrice(double grossPrice) {
    return TableRow(
      children: [
        Text(
          '\nGesamtsumme:\n',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Center(child: Text('')),
        Center(
          child: Text('\n' + grossPrice.toStringAsFixed(2) + ' €'),
        ),
      ],
    );
  }

  /// Build payment options container.
  Widget _buildPaymentOptions() {
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Column(
        children: <Widget>[
          Text('Zahlungsmöglichkeiten'),
          _buildRadioButtonGroupPayment(),
        ],
      ),
    );
  }

  /// Build radio button group for payment options.
  RadioButtonGroup _buildRadioButtonGroupPayment() {
    return RadioButtonGroup(
        activeColor: Theme.of(context).primaryColor,
        labels: <String>[
          'Lastschrift',
          'PayPal',
          'Nachname / Bar vor Ort',
        ],
        picked: _pickedPayment,
        onSelected: (String selected) => {
              setState(() => {_pickedPayment = selected})
            });
  }

  /// Build shipping options container.
  Widget _buildShippingOptions() {
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Column(
        children: <Widget>[
          Text('Liefermöglichkeiten:'),
          _buildRadioButtonGroupShipping(),
          _buildGooglemapsContainer(),
          _buildApoAddressContainer(),
          _buildBillingAdress(),
        ],
      ),
    );
  }

  /// Build radio button group for shipping options.
  RadioButtonGroup _buildRadioButtonGroupShipping() {
    return RadioButtonGroup(
        activeColor: Theme.of(context).primaryColor,
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
                      {_deliverToApo = true}
                    else
                      {_deliverToApo = false}
                  })
            });
  }

  /// Build billing/shipping address container.
  Widget _buildBillingAdress() {
    String address =
        _shippingAddress != '' ? _shippingAddress : 'Lieferadresse fehlt!';
    if (!_deliverToApo) {
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
                  Text('Lieferadresse:',
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

  /// Build google maps container for maps view in shipping options.
  Widget _buildGooglemapsContainer() {
    if (_pickedApo != null) {
      return Visibility(
        visible: _deliverToApo,
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
                      markers: Set<Marker>.of(_markers.values),
                      //onTap: MapsHelper.openMap(currentMarker.geometry.location.lat, currentMarker.geometry.location.lng),
                    ),
                    _buildSearchApoButton(),
                  ],
                )),
            _buildApoPickUpContainer(),
          ],
        ),
      );
    } else {
      if (_deliverToApo) {
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

  /// Build search drug store button.
  Widget _buildSearchApoButton() {
    return Positioned(
      right: 10.0,
      top: 10.0,
      child: Opacity(
        opacity: 0.6,
        child: FloatingActionButton.extended(
          icon: Icon(Icons.fullscreen),
          label: Text('Auswahl'),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(context,
                NoAnimationMaterialPageRoute(builder: (context) => Maps()));
          },
        ),
      ),
    );
  }

  /// Build pick up at drug store container, that displays the address and the
  /// earliest pick up time at the drug store.
  Widget _buildApoPickUpContainer() {
    var temp = new DateTime.now();
    var date = new DateTime(temp.year, temp.month, temp.day, temp.hour + 2, 30);
    var formatter = new DateFormat('HH:mm - dd.MM.yyyy');
    String formattedDate = formatter.format(date);

    return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Icon(Icons.location_on),
            Column(
              children: <Widget>[
                Text(
                  _pickedApo.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_pickedApo.formattedAddress),
                Text(
                  'Früheste Abholzeit: ' + formattedDate,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              ],
            ),
          ],
        ));
  }

  /// Build main address container
  Widget _buildApoAddressContainer() {
    if (_markerIsTabbed) {
      return Container(
          child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Flexible(
                child: Text(_currentMarker.name),
              ),
              Flexible(child: Text(_currentMarker.formattedAddress)),
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

  /// Build confirmation of order container.
  Widget _buildConfirmationContainer() {
    return new Container(
      padding: EdgeInsets.all(3),
      decoration: _getContainerDecoration(1, 5),
      child: Column(
        children: <Widget>[
          Text('Geschäftsbedingungen und Benachrichtigungen'),
          CheckboxGroup(
              checkColor: Theme.of(context).backgroundColor,
              activeColor: Theme.of(context).primaryColor,
              labels: <String>[
                'AGBs zustimmen',
                'Ich bin damit einverstanden, dass...',
              ],
              onSelected: (List<String> checked) => {
                    _agbIsChecked = false,
                    checked.forEach((it) => {
                          if (it == 'AGBs zustimmen')
                            {_agbIsChecked = true}
                        })
                  }),
          RaisedButton(
            onPressed: goToOrderConfirmed,
            child: Text(
              'Zahlungspflichtig bestellen',
              style: TextStyle(color: Theme.of(context).backgroundColor),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _getContainerDecoration(double borderWidth, double circular) {
    return BoxDecoration(
      border: Border.all(
        color: Theme.of(context).splashColor,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(circular),
    );
  }

  /// Check if user data is incomplete.
  /// If the user data is missing, open Personal page, else set dataIsComplete to [true].
  void _checkData() async {
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
    setState(() {
      _dataIsComplete = true;
    });
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

  /// Opens GoogleMaps page to search for a drug store.
  void _findApo(String selected) async {
    var result = await Navigator.push(
        context, NoAnimationMaterialPageRoute(builder: (context) => Maps()));
    if (result != null) {
      _pickedApo = result;
    }
  }

  /// Set marker when map is created.
  Future _onMapCreated(GoogleMapController mapsController) async {
    _controller = mapsController;

    if (_pickedApo != null) {
      final loc = LatLng(
          _pickedApo.geometry.location.lat, _pickedApo.geometry.location.lng);
      // final loc = Location(_pickedApo.geometry.location.lat, _pickedApo.geometry.location.lng);

      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: loc,
        zoom: 14.0,
      )));

      setState(() {
        addMarker(_pickedApo.id, loc, place: _pickedApo);
      });
    }
  }

  /// Add marker to places list.
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
        colorDescriptor = BitmapDescriptor.hueRose;
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
        if (!_markers.containsKey(markerId)) {
          _markers[markerId] = marker;
        }
      });
    }
  }

  /// Set marker tapped to [true]
  void _onMarkerTapped(id) {
    setState(() {
      _currentMarker = _foundPlaces[id];
      _markerIsTabbed = true;
    });
  }

  /// Confirm order
  /// If AGB's are not checked raise alert message.
  Future<void> goToOrderConfirmed() async {
    if (_agbIsChecked) {
      var alert = createAlert(context);
      alert.show();
    } else {
      // agb not checked
      _buildAlertDialog(
          context, 'AGBs bestätigen', 'Bitte AGBs bestätigen um fortzufahren');
    }
  }

  /// Create password confirmation dialog.
  Alert createAlert(BuildContext context) {
    var alert = Alert(
        context: context,
        title: 'Bestellung mit Passwort bestätigen.',
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            icon: Icon(Icons.lock),
            labelText: 'Passwort',
          ),
        ),
        buttons: [
          DialogButton(
            color: Theme.of(context).primaryColor,
            onPressed: () => _confirmPassword(),
            child: Text(
              'Bestätigen',
              style: TextStyle(
                  color: Theme.of(context).backgroundColor, fontSize: 20),
            ),
          )
        ]);
    return alert;
  }

  /// Check if entered password is correct.
  Future _confirmPassword() async {
    if (await PersonalData.checkPassword(_passwordController.text)) {

      Navigator.pop(context);

      setState(() {
        _dataIsComplete = false;
      });

      /// Adding medicament to [globals.meds] (recent) list and saving it.
      Med m = new Med(widget.item.name, widget.item.pzn, '', true);

      /// Retrieving package leaflet for the medicament.
      List<Med> mPzn = await MedGet.getMeds(widget.item.pzn, 0, 1);
      if (mPzn.length > 0) {
        m.url = mPzn[0].url;
      }

      Helper.globalMedListAdd(m);
      await Helper.globalMedListSave();

      // go to confirmed page
      Navigator.push(
          context,
          NoAnimationMaterialPageRoute(
              builder: (context) => OrderConfirmation()
          )
      );
    }
  }

  /// Build shipping address string.
  Future<String> getShippingAddress() async {
    List<String> adresse = await PersonalData.getAddress();
    if (adresse != null)
      setState(() {
        _shippingAddress = adresse[0] +
            ' ' +
            adresse[1] +
            '\n' +
            adresse[2] +
            '\n' +
            adresse[3] +
            ' ' +
            adresse[4];
      });
  }
}
