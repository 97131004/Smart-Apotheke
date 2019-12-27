import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:location/location.dart' as LocationManager;

class MapsHelper {
  //static String kGoogleApiKey = "AIzaSyAP2X_vG7-hXWunjAhzOyAj7BGwYOTSbU4";
  static String kGoogleApiKey = "AIzaSyAFYotTBY_YeedSjlrOTXsVB7EKx79zR3U";
  static GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  static final CameraPosition _berlin = CameraPosition(
    target: LatLng(52.521918, 13.413215),
    zoom: 10.0,
  );

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

  static String buildPhotoURL(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$kGoogleApiKey';
  }

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

  static CameraPosition getInitialPosition() {
    return _berlin;
  }

  static String getApiKey() {
    return kGoogleApiKey;
  }

  static GoogleMapsPlaces getGoogleMapsPlaces() {
    return _places;
  }
}