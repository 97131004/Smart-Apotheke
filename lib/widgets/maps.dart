import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maph_group3/util/maps_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class Maps extends StatefulWidget {

  Maps({Key key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MapsState();
  }
}

class _MapsState extends State<Maps> {

  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<String, PlacesSearchResult> foundPlaces = <String, PlacesSearchResult>{};
  PlacesSearchResult tabbedPlace;

  var previousMarkerId;

  bool markerIsTabbed = false;
  bool isLoaded = false;

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
              Navigator.pop(context);
            }),
        title: Text('Apotheken in Ihrer Nähe'),
        //actions: <Widget>[],
      ),
      body: Stack(
        children: <Widget>[
          _googleMapsContainer(context),
          _buildContainer(),
          _buildSearchInThisArea(),
        ],
      ),
    );
  }

  Widget _buildSearchInThisArea() {
    return Align(
      alignment: Alignment.topCenter,
        child: Opacity(
            opacity: 0.8,
          child: RaisedButton(
            padding: EdgeInsets.all(10),
            onPressed: searchInSelectedArea,
            child: Row(
              children: <Widget>[
                Icon(Icons.crop_free),
                Padding(
                  padding: EdgeInsets.all(5.0),
                ),
                Text('In diesem Bereich suchen')
              ],
            ),
          ),
        ),
    );
  }

  Widget _googleMapsContainer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        initialCameraPosition: MapsHelper.getInitialPosition(),
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }

  Widget _buildContainer() {
    return Visibility(
        visible: markerIsTabbed,
        child:Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            height: 150.0,
            width:  300.0,
            child: Column(
              children: <Widget>[
                SizedBox(width: 10.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _boxes(),
                ),
              ],
          ),
        ),
      )
    );
  }

  Widget _boxes() {
    return  GestureDetector(
      onTap: () {
        //_gotoLocation(lat,long);
      },
      child:Container(
        child: new FittedBox(
          fit: BoxFit.fill,
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 120,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(8.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: _apoImage(),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 15.0, 5.0),
                      child: detailsContainer(),
                    ),
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }

  Widget detailsContainer() {
    String name = '';
    String addr = '';
    String open = '';
    if(tabbedPlace != null) {
      name = tabbedPlace.name != null ? tabbedPlace.name : '';
      addr = tabbedPlace.formattedAddress != null ? tabbedPlace.formattedAddress : '';
      open = tabbedPlace.openingHours != null ? MapsHelper.getOpenString(tabbedPlace) : '';
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(name,
                style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              )),
        ),
        SizedBox(height:5.0),
        Container(
            child: Text(
              addr,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12.0,
              ),
            )),
        SizedBox(height:5.0),
        Container(
            child: Text(
              open,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold),
            )),
        SizedBox(height:5.0),
        Container(
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.check_circle),
                tooltip: 'Apotheke auswählen',
                onPressed: () => Navigator.pop(context, tabbedPlace),
              ),
              IconButton(
                icon: Icon(Icons.call),
                tooltip: 'Apotheke anrufen',
                onPressed: () => launch('tel://03012345678'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  NetworkImage _apoImage() {
    NetworkImage image = new NetworkImage('https://www.abda.de/fileadmin/_processed_/d/3/csm_Apo_Logo_Neu_HKS13_neues_BE_42f1ed22ad.jpg');
    /*var url = buildPhotoURL(photo);
    NetworkImage image;

    try{
      image = new NetworkImage(url);
    } catch(Exception) {
      image = new NetworkImage('https://www.abda.de/fileadmin/_processed_/d/3/csm_Apo_Logo_Neu_HKS13_neues_BE_42f1ed22ad.jpg');
    }*/
    return image;
  }

  String buildPhotoURL(String photoReference) {
    String apiKey = MapsHelper.getApiKey();
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
  }

  Future searchInSelectedArea() async {
    setState(() {
      isLoaded = false;
    });

    //markers.clear();
    // get current position

    LatLng centerOfMap = await getCenterOfMap();

    addMarker('Mein Standort', centerOfMap);

    // add markers
    final loc = Location(centerOfMap.latitude, centerOfMap.longitude);
    final result = await MapsHelper.getGoogleMapsPlaces().searchByText('apotheke', location: loc, radius: 200);

    setState(() {
      if (result.status == 'OK') {
        result.results.forEach((f){
          if(!foundPlaces.containsKey(f.id)) {
            foundPlaces[f.id] = f;
          }
          addMarker(f.id, LatLng(f.geometry.location.lat, f.geometry.location.lng), place: f);
        });
      }
      isLoaded = true;
    });
  }

  Future _onMapCreated(GoogleMapController mapsController) async {
    controller = mapsController;

    // move to current location
    var location = await MapsHelper.getCurrentLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: 14.0,
    )));
    addMarker('Mein Standort', LatLng(location.latitude, location.longitude));

    // add markers
    final loc = Location(location.latitude, location.longitude);
    final result = await MapsHelper.getGoogleMapsPlaces().searchByText('apotheke', location: loc, radius: 200);

    setState(() {
      if (result.status == 'OK') {
        result.results.forEach((f){
          if(!foundPlaces.containsKey(f.id)) {
            foundPlaces[f.id] = f;
          }
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
    });
  }

  Future<LatLng> getCenterOfMap() async {
    final devicePixelRatio = Platform.isAndroid
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;

    var coords = await controller.getLatLng(ScreenCoordinate(
      x: (context.size.width * devicePixelRatio) ~/ 2.0,
      y: (context.size.height * devicePixelRatio) ~/ 4.0,
    ));

    return coords;
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
      String oh = MapsHelper.getOpenString(place);

      if(colorDescriptor == null) {
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

    if(marker != null) {
      setState(() {
        // adding a new marker to map
        if(!markers.containsKey(markerId)) {
          markers[markerId] = marker;
        }
      });
    }
  }

  Future _onMarkerTapped(id) async {
    setState(() {
      markerIsTabbed = true;
      tabbedPlace = foundPlaces[id];
    });
  }

  /*goToLocation(PlacesSearchResult foundPlace) async {
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(foundPlace.geometry.location.lat, foundPlace.geometry.location.lng),
      zoom: 14.0,
    )));

    setState(() {
      // set back previous marker color back to azure (its not possible to change color retrospectively)
      if(previousMarkerId != null) {
        MarkerId markerId = MarkerId(previousMarkerId);
        Marker temp = markers[markerId];
        markers.remove(markerId);

        Marker newMarker = Marker(
          markerId: markerId,
          position: temp.position,
          infoWindow: temp.infoWindow,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () {
            _onMarkerTapped(previousMarkerId);
          },
        );
        markers[markerId] = newMarker;
      }

      // delete current entry from markers and add same entry as new marker with diff color
      MarkerId markerId = MarkerId(foundPlace.id);
      markers.remove(markerId);
      addMarker(foundPlace.id, LatLng(foundPlace.geometry.location.lat, foundPlace.geometry.location.lng), place: foundPlace, colorDescriptor: BitmapDescriptor.hueGreen);
      previousMarkerId = foundPlace.id;
    });
  }*/
}
