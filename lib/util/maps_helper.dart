import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:location/location.dart' as LocationManager;

/// The class provides methods to handle google maps.
class MapsHelper {
  /// Private google maps api key
  //static String kGoogleApiKey = "***";
  static String kGoogleApiKey = "***";
  static GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  /// Default camera location is Berlin
  static final CameraPosition _berlin = CameraPosition(
    target: LatLng(52.521918, 13.413215),
    zoom: 10.0,
  );

  /// The function searches for places nearby for a given search key and a radius.
  /// Returns a future map of key and [PlaceSearchResult].
  static Future<Map<String, PlacesSearchResult>> findNearbyPlaces(LatLng currentLocation, String searchKey, num radius) async {
    final loc = Location(currentLocation.latitude, currentLocation.longitude);
    final result = await _places.searchByText(searchKey, location: loc, radius: 200);

    if (result.status == 'OK') {
      var foundPlaces;
      result.results.forEach((f){
        if(!foundPlaces.containsKey(f.id)) {
          foundPlaces[f.id] = f;
        }
      });
      return foundPlaces;
    } else {
      return null;
    }
  }

  /// The function returns a string if place is open or not.
  static String getOpenString(PlacesSearchResult result) {
    if(result.openingHours != null) {
      if(result.openingHours.openNow != null) {
        return 'Jetzt geöffnet';
      } else {
        return 'Momentan geschlossen';
      }
    } else {
      return '';
    }
  }

  /// Builds string to obtain photo of google maps place.
  static String buildPhotoURL(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$kGoogleApiKey';
  }

  /// The function returns the current location.
  /// Returns future of [LatLng]
  static Future<LatLng> getCurrentLocation() async {
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

  /// The function launces map in app.
  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  /// Returns initial position as [CameraPosition]
  static CameraPosition getInitialPosition() {
    return _berlin;
  }

  /// Returns API Key. SHould be stored in application properties due to abuse.
  static String getApiKey() {
    return kGoogleApiKey;
  }

  /// Retruns [GoogleMapsPlaces] instance.
  static GoogleMapsPlaces getGoogleMapsPlaces() {
    return _places;
  }
}