import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;
import 'package:collection/collection.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

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

      if (_locationPermission == LocationPermission.denied) {
        _locationPermission = await Geolocator.requestPermission();
      }
    }
  }

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
