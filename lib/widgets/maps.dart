import 'package:flutter/material.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;

class Maps extends StatefulWidget {
  Maps({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MapsState();
  }
}

class _MapsState extends State<Maps> {
  static String kGoogleApiKey = "AIzaSyAP2X_vG7-hXWunjAhzOyAj7BGwYOTSbU4";
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  static final CameraPosition _berlin = CameraPosition(
    target: LatLng(52.521918, 13.413215),
    zoom: 10.0,
  );

  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apotheken in Ihrer Nähe'),
      ),
      body: Center(child: GoogleMap(
        initialCameraPosition: _berlin,
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        onCameraMove: (position) {

        },
        markers: Set<Marker>.of(markers.values),
      ),
      ),
    );
  }

  Future _onMapCreated(GoogleMapController mapsController) async {
    controller = mapsController;

    // move to current location
    var location = await getCurrentLocation();
    controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 13.0,
    )));
    addMarker("Mein Standort", LatLng(location.latitude, location.longitude));

    // add markers
    final loc = Location(location.latitude, location.longitude);
    final result = await _places.searchByText("apotheke", location: loc, radius: 1000);

    setState(() {
      if (result.status == "OK") {
        result.results.forEach((f){
          print(f.name);
          addMarker(f.name, LatLng(f.geometry.location.lat, f.geometry.location.lng));
        });
      }
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
      return _berlin.target;
    }
  }

  void addMarker(var id, LatLng latlng) {
    final MarkerId markerId = MarkerId(id);

    final Marker marker = Marker(
      markerId: markerId,
      position: latlng,
      infoWindow: InfoWindow(title: id, snippet: '*'),
      //onTap: () {
      //  _onMarkerTapped(markerId);
      //},
    );

    setState(() {
      // adding a new marker to map
      if(!markers.containsKey(markerId)) {
        markers[markerId] = marker;
      }
    });
  }
}
