import 'dart:async';

import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/booking_controller.dart';
import 'package:taxi4hire/controller/map_controller.dart';
import 'package:taxi4hire/controller/user_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'dart:developer' as developer;

import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';

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
        Geolocator.getPositionStream().listen((Position position) async {
      userCurrentLocation = position;
      String humanReadableAddress =
          await AssistantMethods.searchAddressForGeographicCoordinates(
              position, context);
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

    MapController.checkIfLocationPermissionAllowed(permission);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please enable your Location Services");
      userModelCurrentInfo = null;
      currentFirebaseUser = null;
      await firebaseAuth.signOut();
      Navigator.popAndPushNamed(context, SignInScreen.routeName);
      Provider.of<AppInfo>(context, listen: false).logOut();
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      developer.log("Location denied",
          name: "HomeTabPage > locateUserPosition()");
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg:
                "Please allow permission for application to access your device's location");
        userModelCurrentInfo = null;
        currentFirebaseUser = null;
        await firebaseAuth.signOut();
        Navigator.popAndPushNamed(context, SignInScreen.routeName);
        Provider.of<AppInfo>(context, listen: false).logOut();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      developer.log("Location deniedForever",
          name: "HomeTabPage > locateUserPosition()");
      Fluttertoast.showToast(
          msg:
              "Please allow permission for application to access your device's location");
      userModelCurrentInfo = null;
      currentFirebaseUser = null;
      await firebaseAuth.signOut();
      Navigator.popAndPushNamed(context, SignInScreen.routeName);
      Provider.of<AppInfo>(context, listen: false).logOut();
      return;
    }
    Position cPosition;
    try {
      cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userCurrentLocation = cPosition;
    } catch (exception) {
      developer.log("Exception occured : " + exception.toString(),
          name: "HomeTabPage > locateUser");
    }

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
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) {
        periodicUpdateMarkerSetState();
      }
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
    streamSubscriptionLivePosition!.cancel();
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
