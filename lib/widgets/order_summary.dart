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
import 'package:rflutter_alert/rflutter_alert.dart';

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

  PlacesSearchResult currentMarker;
  PlacesSearchResult _pickedApo;

  bool agbIsChecked = false;
  bool dataIsComplete = false;
  bool visibilityShippingCosts = false;
  bool deliverToApo = false;
  bool markerIsTabbed = false;
  bool isLoaded = false;

  String shippingAddress = '';
  String _pickedDelivered = 'Nach Hause liefern lassen ( + 2.99 € )';
  String _pickedPayment = 'Lastschrift';

  TextEditingController passwordController = new TextEditingController();

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
        title: Text('Bestellübersicht'),
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
          horizontalInside: BorderSide(width: 1.0, color: Theme.of(context).splashColor),
        ),
        columnWidths: {
          0: FlexColumnWidth(1.0),//FixedColumnWidth(MediaQuery.of(context).size.width * 0.65),
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
                    '\n' +
                    widget.item.name +
                    '\n' +
                    widget.item.dosage +
                    '\n',
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

  TableRow _buildTableRowTaxAndShipping(double tax, double shippingCosts){
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
        }
    );
  }

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
              {deliverToApo = true}
            else
              {deliverToApo = false}
          })
        }
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

  Widget _buildGooglemapsContainer() {
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
                    _buildSearchApoButton(),
                  ],
                )),
            _buildApoPickUpContainer(),
          ],
        ),
      );
    } else {
      if (deliverToApo) {
        return Container(
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () => {
              Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Maps())),
            },
          ),
        );
      } else {
        return Container();
      }
    }
  }

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
            Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Maps()));
          },
        ),
      ),
    );
  }

  Widget _buildApoPickUpContainer() {
    var temp = new DateTime.now();
    var date = new DateTime(temp.year,temp.month, temp.day, temp.hour + 2, 30);
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
                Text(_pickedApo.name, style: TextStyle(fontWeight: FontWeight.bold),),
                Text(_pickedApo.formattedAddress),
                Text('Früheste Abholzeit: ' + formattedDate, style: TextStyle(color: Theme.of(context).errorColor),),
              ],
            ),
          ],
        )
    );
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
          Text('Geschäftsbedingungen und Benachrichtigungen'),
          CheckboxGroup(
              checkColor: Theme.of(context).backgroundColor,
              activeColor: Theme.of(context).primaryColor,
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
    setState(() {
      dataIsComplete = true;
    });
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

  Future<void> goToOrderConfirmed() async {
    if (agbIsChecked) {
      var alert = createAlert(context);
      alert.show();
    } else {
      // agb not checked
      _buildAlertDialog(
          context, 'AGBs bestätigen', 'Bitte AGBs bestätigen um fortzufahren');
    }
  }

  Alert createAlert(BuildContext context) {
    var alert = Alert(
        context: context,
        title: 'Bestellung mit Passwort bestätigen.',
        content: TextField(
          controller: passwordController,
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
              style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 20),
            ),
          )
        ]);
    return alert;
  }

  Future _confirmPassword() async {
    if (await PersonalData.checkPassword(passwordController.text)) {
      // go to confirmed page
      Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => OrderConfirmation()));
    }
  }

  Future<String> getShippingAddress() async {
    List<String> adresse = await PersonalData.getadresse();
    if (adresse != null)
      setState(() {
        shippingAddress = adresse[0] +
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
