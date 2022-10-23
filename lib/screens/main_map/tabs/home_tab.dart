import 'dart:async';

import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/screens/main_map/widget/inherited_widget.dart';
import 'package:taxi4hire/screens/main_map/widget/source_destination_map_data.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  List<LatLng> polylineCoordinates = [];
  Set<Marker> markersSet = {};

  var geoLocator = Geolocator();

  Timer? _timer;

  Future<void> getTaxiAvailability() async {
    print("Debug : getTaxiAvailability");
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "assets/images/car.png",
    );
    var url = Uri.https('api.data.gov.sg', '/v1/transport/taxi-availability');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("Debug : getTaxiAvailability > updating Markers");
      Set<Marker> newMarkerSet = {};
      print(
          "\nDEBUG : home_tab > getTaxiAvailability > response.statusCode == 200");
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

      setState(() {
        markersSet.clear();
        markersSet = newMarkerSet;
      });

      Provider.of<AppInfo>(context, listen: false)
          .updateTaxiMarkerSets(markersSet);

      print('\nDEBUG :Printing  Map <markers> -> ' + markersSet.toString());
    } else {
      print('\nDEBUG :Request failed with status: ${response.statusCode}.');
    }

    print("\nDEBUG : home_tab > getTaxiAvailabilty > Print ModalRoute > " +
        ModalRoute.of(context)!.settings.name.toString());
  }

  updateLiveLocationAtRealTime() {
    streamSubscriptionLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentLocation = position;

      LatLng latLngLivePosition =
          LatLng(userCurrentLocation!.latitude, userCurrentLocation!.longitude);

      if (mounted)
        newGoogleMapController!
            .animateCamera(CameraUpdate.newLatLng(latLngLivePosition));
    });
  }

  locateUserPosition() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Getting your location..");
        });
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("Location not available");
      }
    }
    Position cPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userCurrentLocation = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentLocation!.latitude, userCurrentLocation!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    if (mounted)
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoordinates(
              userCurrentLocation!, context);
    // print("This is your current readable address : " + humanReadableAddress);
    Navigator.pop(context);
  }

  Future<void> drawPolyLineFromSourceToDestination() async {
    var sourcePosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var sourceLatLng = LatLng(
        sourcePosition!.locationLatitude!, sourcePosition.locationLongitude!);

    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            sourceLatLng, destinationLatLng);

    print("\nDEBUG : home_tab > drawPolyLineFromSourceToDestination\n");
    print("These are the points = ");
    print(directionDetailsInfo!.e_points);
  }

  @override
  void initState() {
    super.initState();
    // getTaxiAvailability();
    // _timer = new Timer.periodic(
    //     const Duration(seconds: 60), (_) => getTaxiAvailability());
  }

  @override
  void dispose() {
    //_timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          markers: (Provider.of<AppInfo>(context).markersSet != null)
              ? Provider.of<AppInfo>(context).markersSet!
              : markersSet,
          initialCameraPosition: kSingaporeDefaultLocation,
          onMapCreated: (GoogleMapController controller) async {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locateUserPosition();
            updateLiveLocationAtRealTime();
            print("\nDEBUG : home_tab > build > onMapCreated > " +
                userModelCurrentInfo!.role.toString());
            setState(() {});
            if (userModelCurrentInfo!.role == 0) {
              //User is Driver, display Taxis
              if (Provider.of<AppInfo>(context, listen: false).markersSet ==
                  null) {
                getTaxiAvailability();
              }
            } else {
              //User is Passenger, display Taxi Stand
              getTaxiAvailability();
            }
          },
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
