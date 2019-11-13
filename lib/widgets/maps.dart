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
  Map<String, PlacesSearchResult> foundPlaces = <String, PlacesSearchResult>{};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // todo: go back to previous page
            }),
        title: Text('Apotheken in Ihrer Nähe'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                // todo: go to next page
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _googleMapsContainer(context),
        ],
      ),
    );
  }

  Widget _googleMapsContainer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        initialCameraPosition: _berlin,
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        onCameraMove: (position) {

        },
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }

  Future _onMapCreated(GoogleMapController mapsController) async {
    controller = mapsController;

    // move to current location
    var location = await getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
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
          if(!foundPlaces.containsKey(f.id)) {
            foundPlaces[f.id] = f;
          }
          addMarker(f.id, LatLng(f.geometry.location.lat, f.geometry.location.lng), place: f);
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

  void addMarker(var id, LatLng latlng, {PlacesSearchResult place}) {
    final MarkerId markerId = MarkerId(id);
    Marker marker;

    if(id == "Mein Standort") {
      marker = Marker(
          markerId: markerId,
          position: latlng,
          infoWindow: InfoWindow(title: id, snippet: '')
      );
    } else {
      var open = place.openingHours.openNow? 'Jetzt geöffnet' : 'Momentan geschlossen';
      marker = Marker(
          markerId: markerId,
          position: latlng,
          infoWindow: InfoWindow(title: place.name, snippet: open),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () {
            _onMarkerTapped(markerId);
          },
      );
    }

    setState(() {
      // adding a new marker to map
      if(!markers.containsKey(markerId)) {
        markers[markerId] = marker;
      }
    });
  }

  void _onMarkerTapped(id) {
    // todo: open place info
  }
}
