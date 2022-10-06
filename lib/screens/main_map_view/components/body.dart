import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Set<Marker> _markers = {};

  static const LatLng sourceLocation = LatLng(1.3509, 103.7545);
  static const LatLng destination = LatLng(1.35003, 103.75);
  LatLng _lastMapPosition = sourceLocation;

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  List<Marker> markersList = [];
  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  //   _controller.complete(controller);

  //   LatLngBounds bound;
  //   if (destination.latitude > sourceLocation.latitude &&
  //       destination.longitude > sourceLocation.longitude) {
  //     bound = LatLngBounds(southwest: sourceLocation, northeast: destination);
  //   } else if (destination.longitude > sourceLocation.longitude) {
  //     bound = LatLngBounds(
  //         southwest: LatLng(destination.latitude, sourceLocation.longitude),
  //         northeast: LatLng(sourceLocation.latitude, destination.longitude));
  //   } else if (destination.latitude > sourceLocation.latitude) {
  //     bound = LatLngBounds(
  //         southwest: LatLng(sourceLocation.latitude, destination.longitude),
  //         northeast: LatLng(destination.latitude, sourceLocation.longitude));
  //   } else {
  //     bound = LatLngBounds(southwest: destination, northeast: sourceLocation);
  //   }

  //   setState(() {});

  //   CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
  //   this.mapController.animateCamera(u2).then((void v) {
  //     checkCameraUpdate(u2, this.mapController);
  //   });
  // }

  Future<void> getTaxiAvailability() async {
    var url = Uri.https('api.data.gov.sg', '/v1/transport/taxi-availability');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      List<dynamic> features =
          jsonResponse["features"][0]["geometry"]["coordinates"];

      for (var i = 0; i < features.length; i++) {
        print("Print i : " + i.toString());
        Marker marker = Marker(
          markerId: MarkerId("marker_id_" + i.toString()),
          position: LatLng(
            double.parse(features[i][1].toString()),
            double.parse(features[i][0].toString()),
          ),
          infoWindow: InfoWindow(
            title: "marker_id_" + i.toString(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        markersList.add(marker);
      }
      print('Printing  Map <markers> -> ' + markersList.toString());
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    Marker firstMarker = Marker(
      markerId: MarkerId("source"),
      position: LatLng(sourceLocation.latitude, sourceLocation.longitude),
      infoWindow: InfoWindow(
        title: "Source Location",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Marker secondMarker = Marker(
      markerId: MarkerId("destination"),
      position: LatLng(destination.latitude, destination.longitude),
      infoWindow: InfoWindow(
        title: "Destination",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    markersList.add(firstMarker);
    markersList.add(secondMarker);

    setState(() {});
  }

  void checkCameraUpdate(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      checkCameraUpdate(u, c);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void getCurrentLocation() async {
    print("Inside getCurrentLocation");
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(newLoc.latitude!, newLoc.longitude!),
              zoom: 16,
            ),
          ),
        );

        setState(() {});
      },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      FlutterConfig.get('MAP_API_KEY'),
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    // getCurrentLocation();
    getPolyPoints();
    getTaxiAvailability();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
        // currentLocation == null
        //     ? const Center(child: Text("Loading"))
        //     :
        GoogleMap(
      onMapCreated: (mapController) {
        _controller.complete(mapController);
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(sourceLocation!.latitude!, sourceLocation!.longitude!),
        zoom: 16,
      ),
      // polylines: {
      //   Polyline(
      //       polylineId: PolylineId("route"), points: polylineCoordinates)
      // },
      markers: markersList.map((e) => e).toSet(),
      // markers: {
      //   Marker(
      //     markerId: MarkerId("currentLocation"),
      //     position: LatLng(
      //         currentLocation!.latitude!, currentLocation!.longitude!),
      //   ),
      //   Marker(
      //     markerId: MarkerId("source"),
      //     position: sourceLocation,
      //   ),
      //   Marker(
      //     markerId: MarkerId("destination"),
      //     position: destination,
      //   ),
      // },
    );
    //   return currentLocation == null
    //       ? const Center(child: Text("Loading"))
    //       : GoogleMap(
    //           onMapCreated: (mapController) {
    //             _controller.complete(mapController);
    //           },
    //           initialCameraPosition: CameraPosition(
    //             target: LatLng(
    //                 currentLocation!.latitude!, currentLocation!.longitude!),
    //             zoom: 14,
    //           ),
    //           polylines: {
    //             Polyline(
    //               polylineId: PolylineId("route"),
    //               points: polylineCoordinates,
    //               color: Colors.black,
    //             ),
    //           },
    //           markers: {
    //             Marker(
    //               markerId: MarkerId("currentLocation"),
    //               position: LatLng(
    //                   currentLocation!.latitude!, currentLocation!.longitude!),
    //             ),
    //             const Marker(
    //               markerId: MarkerId("source"),
    //               position: sourceLocation,
    //             ),
    //             const Marker(
    //               markerId: MarkerId("desination"),
    //               position: destination,
    //             ),
    //           },
    //         );
    // }
  }
}
