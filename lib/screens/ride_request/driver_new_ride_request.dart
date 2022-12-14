import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/components/payment_collection_dialog.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/main.dart';
import 'package:taxi4hire/models/user_ride_request.dart';
import 'dart:developer' as developer;

class DriverNewRideRequestScreen extends StatefulWidget {
  static String routeName = "/driver_new_ride_request";
  const DriverNewRideRequestScreen({Key? key}) : super(key: key);

  @override
  State<DriverNewRideRequestScreen> createState() =>
      _DriverNewRideRequestScreenState();
}

class _DriverNewRideRequestScreenState
    extends State<DriverNewRideRequestScreen> {
  UserRideRequest? localRideRequestDetail = globalRideRequestDetail;

  GoogleMapController? newRideGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  String? buttonTitle = "Arrived";
  Color? buttonColor = kPrimaryColor;
  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? localDriverCurrentPosition;

  String rideRequestStatus = "accepted";
  String durationFromSourceToDestination = "";
  int durationFromSourceToDestinationInt = 0;

  bool isRequestDirectionDetail = false;

  assignedDriverToRideRequest() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("ride_request")
        .child(localRideRequestDetail!.rideRequestId!);

    final databaseStatusReferenceSnapshot =
        await databaseReference.child("status").get();
    Map driverLocationDataMap = {
      //Original is driverCurrentPosition?
      "latitude": userCurrentLocation!.latitude.toString(),
      "longitude": userCurrentLocation!.longitude.toString()
    };

    String status = databaseStatusReferenceSnapshot.value.toString();
    if (status == "accepted") {
      databaseReference.child("driverLatLng").set(driverLocationDataMap);
      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(userModelCurrentInfo!.id);
      databaseReference.child("driverName").set(userModelCurrentInfo!.name);
      databaseReference.child("driverPhone").set(userModelCurrentInfo!.mobile);
      databaseReference
          .child("driverLicensePlate")
          .set(userModelCurrentInfo!.licensePlate);
    } else {
      rideRequestStatus = status;
      if (rideRequestStatus == "arrived") {
        setState(() {
          buttonTitle = "Start Ride Request";
          buttonColor = kSecondaryColor;
        });
      } else if (rideRequestStatus == "onriderequest") {
        setState(() {
          buttonTitle = "End Ride Request";
          buttonColor = kLavenderBlushColor;
        });
      }
    }
  }

  Future<void> drawPolyLineFromSourceToDestination(
      LatLng sourceLatLng, LatLng destinationLatLng) async {
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

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.ePoints!);

    polyLinePositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: kPrimaryColor,
        polylineId: PolylineId("Polyline2"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    double southWestLat;
    double southWestLong;
    double northEastLat;
    double northEastLong;

    if (sourceLatLng.latitude <= destinationLatLng.latitude) {
      southWestLat = sourceLatLng.latitude;
      northEastLat = destinationLatLng.latitude;
    } else {
      northEastLat = sourceLatLng.latitude;
      southWestLat = destinationLatLng.latitude;
    }

    if (sourceLatLng.longitude <= destinationLatLng.longitude) {
      southWestLong = sourceLatLng.longitude;
      northEastLong = destinationLatLng.longitude;
    } else {
      northEastLong = sourceLatLng.longitude;
      southWestLong = destinationLatLng.longitude;
    }
    boundsLatLng = LatLngBounds(
      southwest: LatLng(southWestLat, southWestLong),
      northeast: LatLng(northEastLat, northEastLong),
    );

    newRideGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 60));

    Marker sourceMarker = Marker(
      markerId: MarkerId("sourceId"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationId"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(sourceMarker);
      setOfMarkers.add(destinationMarker);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    assignedDriverToRideRequest();
  }

  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  endRideRequest() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext c) => const ProgressDialog(
        message: "Loading..",
      ),
    );

    var currentPositionLatLng = LatLng(
      userCurrentLocation!.latitude,
      userCurrentLocation!.longitude,
    );

    FirebaseDatabase.instance
        .ref()
        .child("ride_request")
        .child(localRideRequestDetail!.rideRequestId!)
        .child("status")
        .set("ended");

    streamSubscriptionRideRequestLivePosition!.cancel();

    Navigator.pop(context);

    var response = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) => PaymentCollectionDialog(
            paymentAmount: localRideRequestDetail!.price!));

    setState(() {
      print("restart app");
      MyApp.restartApp(context);
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetail == false) {
      isRequestDirectionDetail = true;

      if (userCurrentLocation == null) {
        return;
      }

      var sourceLatLng =
          LatLng(userCurrentLocation!.latitude, userCurrentLocation!.longitude);
      var destinationLatLng;
      if (rideRequestStatus == "accepted") {
        destinationLatLng = localRideRequestDetail!.sourceLatLng;
      } else {
        destinationLatLng = localRideRequestDetail!.destinationLatLng;
      }

      var directionInformation =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              sourceLatLng, destinationLatLng);

      if (directionInformation != null) {
        if (mounted) {
          setState(() {
            durationFromSourceToDestination =
                directionInformation.durationText!;
            durationFromSourceToDestinationInt =
                directionInformation.durationValue!;
          });
        }
      }

      isRequestDirectionDetail = false;
    }
  }

  updateLiveLocationAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionRideRequestLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      userCurrentLocation = position;
      localDriverCurrentPosition = position;

      LatLng latLngDriverPosition =
          LatLng(userCurrentLocation!.latitude, userCurrentLocation!.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("AnimatedMarker"),
        position: latLngDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(title: "Your current location"),
      );

      CameraPosition cameraPosition =
          CameraPosition(target: latLngDriverPosition, zoom: 15);
      setState(() {
        if (mounted) {
          newRideGoogleMapController!
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

          setOfMarkers.removeWhere(
              (element) => element.markerId.value == "AnimatedMarker");
          setOfMarkers.add(animatingMarker);
        }
      });
      oldLatLng = latLngDriverPosition;
      updateDurationTimeAtRealTime();

      Map driverLatLngDataMap = {
        "latitude": userCurrentLocation!.latitude,
        "longitude": userCurrentLocation!.longitude,
      };

      FirebaseDatabase.instance
          .ref()
          .child("ride_request")
          .child(localRideRequestDetail!.rideRequestId!)
          .child("driverLocation")
          .set(driverLatLngDataMap);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamSubscriptionRideRequestLivePosition!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();
    final rideRequestDetail =
        ModalRoute.of(context)!.settings.arguments as UserRideRequest;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            markers: setOfMarkers,
            // circles: setOfCircle,
            polylines: setOfPolyline,
            initialCameraPosition: kSingaporeDefaultLocation,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var driverCurrentLatLng = LatLng(userCurrentLocation!.latitude,
                  userCurrentLocation!.longitude);

              var userPickUpLatLng = localRideRequestDetail!.sourceLatLng;

              drawPolyLineFromSourceToDestination(
                  driverCurrentLatLng, userPickUpLatLng!);

              updateLiveLocationAtRealTime();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(1, 0),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    //Duration
                    Text(
                      durationFromSourceToDestination,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.black54,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          localRideRequestDetail!.userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: kPrimaryColor,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    //Pick up Address
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/source.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              localRideRequestDetail!.sourceAddress!,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //Drop off Address
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/destination.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              localRideRequestDetail!.destinationAddress!,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24.0,
                    ),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.black54,
                    ),

                    const SizedBox(
                      height: 15.0,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (rideRequestStatus == "accepted") {
                            developer.log("durationFromSourceToDesitnation : " +
                                (durationFromSourceToDestinationInt)
                                    .toString());

                            if (durationFromSourceToDestinationInt <= 240) {
                              rideRequestStatus = "arrived";

                              FirebaseDatabase.instance
                                  .ref()
                                  .child("ride_request")
                                  .child(localRideRequestDetail!.rideRequestId!)
                                  .child("status")
                                  .set(rideRequestStatus);

                              FirebaseDatabase.instance
                                  .ref()
                                  .child("users")
                                  .child(localRideRequestDetail!.userId!)
                                  .child("ride_request")
                                  .set(rideRequestStatus);

                              setState(() {
                                buttonTitle = "Start Ride Request";
                                buttonColor = kSecondaryColor;
                              });

                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext c) => ProgressDialog(
                                  message: "Loading..",
                                ),
                              );

                              await drawPolyLineFromSourceToDestination(
                                localRideRequestDetail!.sourceLatLng!,
                                localRideRequestDetail!.destinationLatLng!,
                              );

                              Navigator.pop(context);
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "You've yet to reached the pickup point!");
                            }
                          } else if (rideRequestStatus == "arrived") {
                            rideRequestStatus = "onriderequest";

                            FirebaseDatabase.instance
                                .ref()
                                .child("ride_request")
                                .child(localRideRequestDetail!.rideRequestId!)
                                .child("status")
                                .set(rideRequestStatus);

                            FirebaseDatabase.instance
                                .ref()
                                .child("users")
                                .child(localRideRequestDetail!.userId!)
                                .child("ride_request")
                                .set(rideRequestStatus);

                            setState(() {
                              buttonTitle = "End Ride Request";
                              buttonColor = kLavenderBlushColor;
                            });

                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext c) => ProgressDialog(
                                message: "Loading..",
                              ),
                            );

                            Navigator.pop(context);
                          } else if (rideRequestStatus == "onriderequest") {
                            if (durationFromSourceToDestinationInt <= 240) {
                              endRideRequest();
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "You've yet to reached the destination!");
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 25,
                        ),
                        label: Text(
                          buttonTitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
