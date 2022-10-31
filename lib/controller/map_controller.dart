import 'dart:convert' as convert;

import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;
import 'package:collection/collection.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/assistants/request_assistant.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/models/directions.dart';
import 'package:taxi4hire/models/predicted_places.dart';

class MapController {
  static void checkIfLocationPermissionAllowed(
      LocationPermission? _locationPermission) async {
    _locationPermission = await Geolocator.checkPermission();

    if (_locationPermission == LocationPermission.always ||
        _locationPermission == LocationPermission.whileInUse) {
      return;
    }

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();

      if (_locationPermission == LocationPermission.deniedForever) {
        _locationPermission = await Geolocator.requestPermission();
      }
    }
  }

  static Future<void> locateUserPosition() async {
    LocationPermission permission;

    permission = await Geolocator.requestPermission();

    MapController.checkIfLocationPermissionAllowed(permission);

    Position cPosition;
    try {
      cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userCurrentLocation = cPosition;
    } catch (exception) {
      developer.log("Exception occured : " + exception.toString(),
          name: "MapController > locateUserPosition");
    }
  }

  /*
  GoogleMap API

  */
  static Future<List<PredictedPlaces>> findAutoCompletePlaces(
      String inputText, List<PredictedPlaces> oldPlacesPredictedList) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=${FlutterConfig.get('MAP_API_KEY')}&components=country:SG";

      var responseAutoCompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch == "error_occured") {
        return oldPlacesPredictedList;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placesPredictionsList = (placePredictions as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        // setState(() {
        //   placesPredictedList = placesPredictionsList;
        // });
        return placesPredictionsList;
      }
      developer.log("setState > placesPredictedList = placesPredictionList",
          name: "search_places_screen > findPlacesAutoCompleteSearch");
    }
    return oldPlacesPredictedList;
  }

  static void getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Setting up drop off location",
      ),
    );

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${FlutterConfig.get('MAP_API_KEY')}";

    var responsePlaceId =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);
    if (responsePlaceId == "error_occured") {
      developer.log("responsePlaceId == 'error_occured'",
          name: "PlacePredictionTile > getPlaceDirectionDetails");
      return;
    }

    if (responsePlaceId["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responsePlaceId["result"]["name"];
      directions.locationLatitude =
          responsePlaceId["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responsePlaceId["result"]["geometry"]["location"]["lng"];
      directions.locationId = placeId;
      developer.log("responsePlaceId['status'] == 'OK'",
          name: "PlacePredictionTile > getPlaceDirectionDetails");

      developer.log("Location Name : " + directions.locationName!,
          name: "PlacePredictionTile > getPlaceDirectionDetails");

      developer.log(
          "Location Latitude : " + directions.locationLatitude!.toString(),
          name: "PlacePredictionTile > getPlaceDirectionDetails");

      developer.log(
          "Location Longitude : " + directions.locationLongitude!.toString(),
          name: "PlacePredictionTile > getPlaceDirectionDetails");

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      Navigator.pop(context, "obtainedDropOff");
    }
  }

  /*
  Data Gov API

  */

  static Future<Set<Marker>> getTaxiAvailability() async {
    developer.log("getTaxiAvailability() was called", name: "MapController");
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/car.png",
    );
    var url = Uri.https('api.data.gov.sg', '/v1/transport/taxi-availability');

    Set<Marker> newMarkerSet = {};
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      developer.log("response.statusCode == 200",
          name: "MapController > getTaxiAvailability()");
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> features =
          jsonResponse["features"][0]["geometry"]["coordinates"];

      for (var i = 0; i < features.length; i++) {
        Marker marker = Marker(
          markerId: MarkerId("Taxi - " + i.toString()),
          position: LatLng(
            double.parse(features[i][1].toString()),
            double.parse(features[i][0].toString()),
          ),
          infoWindow: InfoWindow(
            title: "Taxi - " + i.toString(),
          ),
          icon: markerbitmap,
        );

        newMarkerSet.add(marker);
      }

      return newMarkerSet;
    } else {
      developer.log("Request failed with status: ${response.statusCode}.",
          name: "HomeTabPage > getTaxiAvailability()");
      return newMarkerSet;
    }
  }

  static Future<Set<Marker>> readLTATaxiStopJson() async {
    Set<Marker> ltaStandMarkerSet = {};
    final String response = await rootBundle
        .loadString('assets/data/lta-taxi-stop-geojson.geojson');

    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/taxi_stand.png",
    );

    var jsonResponse = convert.jsonDecode(response) as Map<String, dynamic>;
    List<dynamic> features = jsonResponse["features"];

    for (var i = 0; i < features.length; i++) {
      String name = features[i]['properties']['Name'].toString();
      String type = features[i]['properties']['Description']
              .toString()
              .contains("TAXI STAND")
          ? "Taxi Stand"
          : "Taxi Stop";

      double latitude =
          double.parse(features[i]['geometry']['coordinates'][1].toString());
      double longitude =
          double.parse(features[i]['geometry']['coordinates'][0].toString());

      Marker marker = Marker(
        markerId: MarkerId(name),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: "Placemark id : " + name,
          snippet: "Type : " + type,
        ),
        icon: markerbitmap,
      );
      ltaStandMarkerSet.add(marker);
    }

    return ltaStandMarkerSet;
  }

  static Future<Set<Marker>> updateTaxiAvailabity(Set<Marker> markerSet) async {
    developer.log("updateTaxiAvailabity() was called", name: "MapController");
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/images/car.png",
    );

    var url = Uri.https('api.data.gov.sg', '/v1/transport/taxi-availability');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> features =
          jsonResponse["features"][0]["geometry"]["coordinates"];

      markerSet
          .removeWhere((marker) => marker.markerId.value.contains("Taxi - "));

      for (var i = 0; i < features.length; i++) {
        Marker marker = Marker(
          markerId: MarkerId("Taxi - " + i.toString()),
          position: LatLng(
            double.parse(features[i][1].toString()),
            double.parse(features[i][0].toString()),
          ),
          infoWindow: InfoWindow(
            title: "Taxi - " + i.toString(),
          ),
          icon: markerbitmap,
        );
        markerSet.add(marker);

        // developer.log("Remove marker : " + oldMarker.toString(),
        //     name: "HomeTabPage > updateTaxiAvailabity()");

        // developer.log("Add marker : " + marker.toString(),
        //     name: "HomeTabPage > updateTaxiAvailabity()");

      }

      developer.log("Updating Markers",
          name: "HomeTabPage > updateTaxiAvailabity()");
      // setState(() {
      //   markersSet.clear();
      //   markersSet = newMarkerSet;
      // });

      return markerSet;
    } else {
      developer.log("Request failed with status: ${response.statusCode}.",
          name: "HomeTabPage > getTaxiAvailability()");
      return markerSet;
    }
  }
}
