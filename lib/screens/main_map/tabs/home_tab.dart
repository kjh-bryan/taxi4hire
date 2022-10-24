import 'dart:async';

import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/map_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'dart:developer' as developer;

class HomeTabPage extends StatefulWidget {
  final int tabNumber;
  const HomeTabPage({Key? key, required this.tabNumber}) : super(key: key);

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

  updateLiveLocationAtRealTime() {
    streamSubscriptionLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentLocation = position;

      LatLng latLngLivePosition =
          LatLng(userCurrentLocation!.latitude, userCurrentLocation!.longitude);

      // if (mounted) {
      //   newGoogleMapController!
      //       .animateCamera(CameraUpdate.newLatLng(latLngLivePosition));
      // }
    });
  }

  locateUserPosition() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return const ProgressDialog(message: "Getting your location..");
        });
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        developer.log("Location not available",
            name: "HomeTabPage > locateUserPosition()");
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

    if (mounted) {
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoordinates(
              userCurrentLocation!, context);

      developer.log(
          "This is your current readable address :" + humanReadableAddress,
          name: "HomeTabPage > locateUserPosition()");
    }
    Navigator.pop(context);
  }

  Future<void> drawPolyLineFromSourceToDestination() async {
    developer.log("drawPolyLineFromSourceToDestination() was called",
        name: "HomeTabPage > drawPolyLineFromSourceToDestination");
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
      builder: (BuildContext context) => const ProgressDialog(
        message: "Please wait...",
      ),
    );
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            sourceLatLng, destinationLatLng);

    developer.log(
        "directionDetailsInfo distance Text :" +
            directionDetailsInfo!.distanceText!.toString(),
        name: "HomeTabPage > drawPolyLineFromSourceToDestination");
  }

  periodicUpdateMarkerSetState() async {
    developer.log("get final int tabNumber : " + widget.tabNumber.toString(),
        name: "Home Tab > peridoicUpdateMarkerSetState");
    developer.log(
        "newMarkers = await MapController.updateTaxiAvailabity(markersSet)",
        name: "Home Tab > peridoicUpdateMarkerSetState");
    Set<Marker> newMarkers =
        await MapController.updateTaxiAvailabity(markersSet);

    developer.log("await done from MapController",
        name: "Home Tab > peridoicUpdateMarkerSetState");
    if (Provider.of<AppInfo>(context, listen: false).tabNumber == 0) {
      setState(() {
        markersSet = newMarkers;
        developer.log("Settings newMarkers to markerSet in SetState",
            name: "Home Tab > peridoicUpdateMarkerSetState");
      });
    }
  }

  setUpTaxiStandAndTaxiMarker() async {
    Set<Marker> ltaStandMarkerSet = await MapController.readLTATaxiStopJson();
    Set<Marker> taxiMarkerSet = await MapController.getTaxiAvailability();

    if (Provider.of<AppInfo>(context, listen: false).tabNumber == 0) {
      setState(() {
        markersSet = {...ltaStandMarkerSet, ...taxiMarkerSet};
      });
    }

    Provider.of<AppInfo>(context, listen: false)
        .updateTaxiMarkerSets(markersSet);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      periodicUpdateMarkerSetState();
    });
  }

  @override
  void initState() {
    super.initState();
    setUpTaxiStandAndTaxiMarker();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(
            bottom: 20,
          ),
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
            developer.log("onMapCreated", name: "HomeTabPage > build");
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
