import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/util/personal_data.dart';
import 'package:maph_group3/util/shop_items.dart';
import 'package:maph_group3/widgets/maps.dart';
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
  // google places api credentials
  static String kGoogleApiKey = "AIzaSyAFYotTBY_YeedSjlrOTXsVB7EKx79zR3U";
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  // google maps controller and markers
  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<String, PlacesSearchResult> foundPlaces = <String, PlacesSearchResult>{};

  // initial position
  static final CameraPosition _berlin = CameraPosition(
    target: LatLng(52.521918, 13.413215),
    zoom: 10.0,
  );

  Location loc;

  bool agbIsChecked = false;
  bool dataIsComplete = false;
  bool visibilityShippingCosts = false;
  bool deliverToApo = false;

  bool markerIsTabbed = false;
  PlacesSearchResult currentMarker;
  bool isLoaded = false;
  String oh = '';
  String name = '';
  String formattedAddress = '';
  String shippingAddress = '';

  String _pickedDelivered = 'Nach Hause liefern lassen ( + 2.99 € )';
  String _pickedPayment = 'Lastschrift';

  PlacesSearchResult _pickedApo;

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
                  Text("\nMehrwertsteuer 10%"),
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
              Text("\nGesamtsumme:\n", style: TextStyle(fontWeight: FontWeight.bold),),
              Center(child: Text("")),
              Center(child: Text("\n" + grossPrice.toStringAsFixed(2) + " €"),),
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
              setState(() => {
                  _pickedPayment = selected
              })
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
            activeColor: Colors.green,
            labels: <String>[
              'Nach Hause liefern lassen ( + 2.99 € )',
              'An Apotheke liefern lassen',
            ],
            picked: _pickedDelivered,
            onSelected: (String selected) => {
              _pickedDelivered = selected,
              if(_pickedApo == null) _findApo(selected),
            }
          ),
          _buildGooglemapsContainer(),
          _buildApoAddressContainer(),
          _buildBillingAdress(),
        ],
      ),
    );
  }

  _findApo(String selected) async {
    var result = await Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Maps()));
    if(result != null) {
      _pickedApo = result;
    }
    setState(() => {
      if(selected == 'An Apotheke liefern lassen') {
        deliverToApo = true
      } else {
        deliverToApo = false
      }
    });
  }

  Widget _buildBillingAdress() {
    String address = shippingAddress != '' ? shippingAddress : 'Lieferadresse fehlt!';
    if(!deliverToApo) {
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
                Text("Lieferadresse:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(address),
              ],
            ),
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'Lieferadresse bearbeiten',
              onPressed: () {
                Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Personal()));
              },
            ),
          ],
        )
      );
    } else {
      return Container();
    }
  }

  Widget _buildGooglemapsContainer() {
    if(_pickedApo != null) {
      return Visibility(
        visible: deliverToApo ,
        child: Container(
            decoration: _getContainerDecoration(1, 0),
            height: MediaQuery.of(context).size.height/3,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: new CameraPosition(target: LatLng(52.45654549, 13.52600992)),
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  markers: Set<Marker>.of(markers.values),
                ),
                Positioned(
                    right: 10.0,
                    bottom: 10.0,
                    child: Opacity(
                      opacity: 0.7,
                      child: new FloatingActionButton(
                        child: const Icon(Icons.fullscreen),
                        backgroundColor: Colors.grey,
                        onPressed: () {
                          //Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Maps(loc, foundPlaces: foundPlaces,)));
                        },
                      ),
                    )
                )
              ],
            )
        ),
      );
    } else {
      if(deliverToApo) {
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

  _buildApoAddressContainer() {
    if(markerIsTabbed) {
      return Container(
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Flexible(child: Text(currentMarker.name),),
                  Flexible(child: Text(currentMarker.formattedAddress)),
                ],
              ),
            ],
          )
      );
    } else {
      return Container(
        child: Padding(padding: EdgeInsets.all(5),)
      );
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
            checkColor: Colors.green,
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

  Future _onMapCreated(GoogleMapController mapsController) async {
    controller = mapsController;

    if(_pickedApo != null) {
      final loc = LatLng(_pickedApo.geometry.location.lat, _pickedApo.geometry.location.lng);
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


    // move to current location
    /*var location = await getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 14.0,
    )));
    addMarker('Mein Standort', LatLng(location.latitude, location.longitude));

    // add markers
    final loc = Location(location.latitude, location.longitude);
    final result = await _places.searchByText('apotheke', location: loc, radius: 200);

    setState(() {
      if (result.status == 'OK') {
        result.results.forEach((f){
          if(!foundPlaces.containsKey(f.id)) {
            foundPlaces[f.id] = f;
          }
          print(f.name);
          addMarker(f.id, LatLng(f.geometry.location.lat, f.geometry.location.lng), place: f);
        });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(result.status),
                content: Text(result.errorMessage),
              );
            });
      }
      isLoaded = true;
    });*/
  }

  void addMarker(var id, LatLng latlng, {PlacesSearchResult place, double colorDescriptor}) {
    final MarkerId markerId = MarkerId(id);
    Marker marker;

    if(id == 'Mein Standort') {
      marker = Marker(
          markerId: markerId,
          position: latlng,
          infoWindow: InfoWindow(title: id, snippet: '')
      );
    } else {
      if(place.openingHours != null && place.openingHours.openNow != null) {
        oh = place.openingHours.openNow ? 'Jetzt geöffnet' : 'Momentan geschlossen';
      }
      if(colorDescriptor == null) {
        colorDescriptor = BitmapDescriptor.hueAzure;
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

    if(marker != null) {
      setState(() {
        // adding a new marker to map
        if(!markers.containsKey(markerId)) {
          markers[markerId] = marker;
        }
      });
    }
  }

  _onMarkerTapped(id) {
    name = foundPlaces[id].name;
    formattedAddress = foundPlaces[id].formattedAddress;
    oh = foundPlaces[id].openingHours.openNow ? 'Jetzt geöffnet' : 'Momentan geschlossen';
    setState(() {
      currentMarker = foundPlaces[id];
      markerIsTabbed = true;
    });
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

  Future<String> getShippingAddress() async {
    List<String> adresse = await PersonalData.getadresse();
    if (adresse != null)
      setState(() {
        shippingAddress = adresse[0] + " " + adresse[1] + "\n" + adresse[2] + "\n" + adresse[3] + " " + adresse[4];
      });
  }

}
