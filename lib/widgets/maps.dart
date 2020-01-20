import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maph_group3/util/helper.dart';
import 'package:maph_group3/util/maps_helper.dart';
import 'package:maph_group3/util/no_internet_alert.dart';
import 'package:url_launcher/url_launcher.dart';

/// This class will open a GoogleMaps-instance.
/// Initially it will access the current location and will send an API-request
/// to retrieve drug stores nearby that location.
/// Furthermore the user can search in a defined area.
/// After clicking on a marker, a details container will appear, where the user
/// can select the drug store for the order process or launch a call there.
class Maps extends StatefulWidget {

  Maps({Key key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MapsState();
  }
}

class _MapsState extends State<Maps> {

  /// Maps controller
  GoogleMapController _controller;
  /// global maps to buffer markers
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<String, PlacesSearchResult> _foundPlaces = <String, PlacesSearchResult>{};
  PlacesSearchResult _tabbedPlace;

  /// when markerIsTabbed is [true], container with details appears
  bool _markerIsTabbed = false;

  @override
  void initState() {
    /// check for internet connection
    Helper.hasInternet().then((internet) {
      if (internet == null || !internet) {
        NoInternetAlert.show(context);
      }
    });

    super.initState();
  }

  /// Build the main page.
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

  /// Build a floating button that searches drug stores at the current location.
  /// The current location in this context is the center of the screen.
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

  /// Build the google maps container and sets markers if there exist any.
  Widget _googleMapsContainer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        initialCameraPosition: MapsHelper.getInitialPosition(),
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        markers: Set<Marker>.of(_markers.values),
      ),
    );
  }

  /// Build the details container.
  Widget _buildContainer() {
    return Visibility(
        visible: _markerIsTabbed,
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

  /// Warps the details container in a gesture detectors (not used currently).
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

  /// Build the actual drug store details section with data from the
  /// [PlaceSearchResult].
  Widget detailsContainer() {
    String name = '';
    String addr = '';
    String open = '';
    if(_tabbedPlace != null) {
      name = _tabbedPlace.name != null ? _tabbedPlace.name : '';
      addr = _tabbedPlace.formattedAddress != null ? _tabbedPlace.formattedAddress : '';
      open = _tabbedPlace.openingHours != null ? MapsHelper.getOpenString(_tabbedPlace) : '';
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
                onPressed: () => Navigator.pop(context, _tabbedPlace),
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

  /// Returns an image for the drugstore. Currently a default image is used
  /// due to the pricing of the google maps/places API.
  /// The free usage of the API is restricted only to a few requests a day.
  NetworkImage _apoImage() {
    NetworkImage image = new NetworkImage('https://www.abda.de/fileadmin/_processed_/d/3/csm_Apo_Logo_Neu_HKS13_neues_BE_42f1ed22ad.jpg');
    /// this is commented here, because it will reduce amount of free google api requests per day
    /*var url = buildPhotoURL(photo);
    NetworkImage image;

    try{
      image = new NetworkImage(url);
    } catch(Exception) {
      image = new NetworkImage('https://www.abda.de/fileadmin/_processed_/d/3/csm_Apo_Logo_Neu_HKS13_neues_BE_42f1ed22ad.jpg');
    }*/
    return image;
  }

  /// Build the https-string for the requested drug store.
  String buildPhotoURL(String photoReference) {
    String apiKey = MapsHelper.getApiKey();
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
  }

  /// Method will search for drug stores in the selected area and set markers
  /// on the map.
  /// The current location is the center of the map in this context.
  Future searchInSelectedArea() async {
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
          if(!_foundPlaces.containsKey(f.id)) {
            _foundPlaces[f.id] = f;
          }
          addMarker(f.id, LatLng(f.geometry.location.lat, f.geometry.location.lng), place: f);
        });
      }
    });
  }

  /// When the maps widget is created, the current location is determined and
  /// drug stores nearby will be searched and added to the markers list.
  /// Shows an error message on failure.
  Future _onMapCreated(GoogleMapController mapsController) async {
    _controller = mapsController;

    // move to current location
    var location = await MapsHelper.getCurrentLocation();
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
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
          if(!_foundPlaces.containsKey(f.id)) {
            _foundPlaces[f.id] = f;
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
    });
  }

  /// Calculate the center of the screen and return the current location for
  /// this position.
  Future<LatLng> getCenterOfMap() async {
    final devicePixelRatio = Platform.isAndroid
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;

    var coords = await _controller.getLatLng(ScreenCoordinate(
      x: (context.size.width * devicePixelRatio) ~/ 2.0,
      y: (context.size.height * devicePixelRatio) ~/ 4.0,
    ));

    return coords;
  }

  /// Add a marker to the marker list, depending on the given [PlaceSearchResult].
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
        if(!_markers.containsKey(markerId)) {
          _markers[markerId] = marker;
        }
      });
    }
  }

  /// Update when marker is tabbed.
  Future _onMarkerTapped(id) async {
    setState(() {
      _markerIsTabbed = true;
      _tabbedPlace = _foundPlaces[id];
    });
  }

  /// Move to specific location. Not used right now.
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
