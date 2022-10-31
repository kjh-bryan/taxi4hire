import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/components/pay_request_dialog.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/booking_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/main.dart';
import 'package:taxi4hire/models/direction_details_info.dart';
import 'package:taxi4hire/models/directions.dart';
import 'package:taxi4hire/models/taxi_type_list.dart';
import 'package:taxi4hire/models/user_model.dart';
import 'package:taxi4hire/screens/main_map/components/search_places_screen.dart';
import 'package:taxi4hire/size_config.dart';

import 'dart:developer' as developer;

import 'package:url_launcher/url_launcher.dart';

class BookRequestsTabPage extends StatefulWidget {
  const BookRequestsTabPage({Key? key}) : super(key: key);

  @override
  State<BookRequestsTabPage> createState() => _BookRequestsTabPageState();
}

class _BookRequestsTabPageState extends State<BookRequestsTabPage>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  final panelController = PanelController();
  final List<TaxiTypeList> taxiList = [];

  DirectionDetailsInfo? tripDirectionDetailsInfo;
  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  DatabaseReference? referenceRideRequest;
  DatabaseReference? userReference;
  int selectedTaxi = 0;

  double searchLocationContainerHeight = 100; // 100
  double selectARideContainerHeight = 0;
  double findingARideContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  double googleMapPadding = 100;
  double bottomPadding = 20;

  String userRideRequestStatus = "";
  String isRequestingStatus = "idle";
  String driverRideStatus = "Taxi is arriving";
  bool existingRide = false;
  bool hasDriver = false;
  bool requestPositionInfo = true;

  Position? userCurrentLocation;
  var geoLocator = Geolocator();

  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  showSelectARideUI() {
    setState(() {
      selectARideContainerHeight = SizeConfig.screenHeight! * 0.38;
      searchLocationContainerHeight = 0;
    });
  }

  showFindingARideUI() {
    setState(() {
      findingARideContainerHeight = SizeConfig.screenHeight! * 0.38;
      selectARideContainerHeight = 0;
      searchLocationContainerHeight = 0;
    });
  }

  cancelFindingARideUI() {
    setState(() {
      selectARideContainerHeight = SizeConfig.screenHeight! * 0.38;
      findingARideContainerHeight = 0;
    });
  }

  assignedDriverInfoUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      selectARideContainerHeight = 0;
      assignedDriverInfoContainerHeight = SizeConfig.screenHeight! * 0.38;
    });
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentLocation = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentLocation!.latitude, userCurrentLocation!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    if (newGoogleMapController != null && !existingRide)
      newGoogleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            userCurrentLocation!, context);

    Future.delayed(Duration(seconds: 3), () {
      checkIfExistingRideRequest();
    });
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
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Please wait...",
      ),
    );
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            sourceLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });
    Navigator.pop(context);
    developer.log("drawPolyLineFromSourceToDestination",
        name: "BookRequestTab");

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.ePoints!);

    developer.log(
        "decodedPolyLinePointsResultList " +
            decodedPolyLinePointsResultList.toString(),
        name: "BookRequestTab");
    pLineCoordinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: kPrimaryColor,
        polylineId: const PolylineId("PolylineID2"),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLineSet.add(polyline);
      developer.log("setState Polyline",
          name: "BookRequestTab > drawPolyLineFromSourceToDestination");
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

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 70));

    Marker sourceMarker = Marker(
      markerId: const MarkerId("sourceId"),
      infoWindow:
          InfoWindow(title: sourcePosition.locationName, snippet: "From"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationId"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(sourceMarker);
      markersSet.add(destinationMarker);
    });

    Circle sourceCircle = Circle(
      circleId: const CircleId("sourceId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: sourceLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationId"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(sourceCircle);

      circlesSet.add(destinationCircle);
    });

    if (!existingRide) addTaxiToList(directionDetailsInfo);
  }

  addTaxiToList(directionDetailsInfo) {
    if (directionDetailsInfo != null) {
      showSelectARideUI();
    }
    // double premiumPrice =
    //     AssistantMethods.calculateFareAmountFromSourceToDestination(
    //         directionDetailsInfo, "premium");
    double standardPrice =
        AssistantMethods.calculateFareAmountFromSourceToDestination(
            directionDetailsInfo, "standard");

    // TaxiTypeList tPremium = TaxiTypeList(
    //     imgUrl: "assets/images/premium.png",
    //     type: "Premium",
    //     distance: directionDetailsInfo.distanceText,
    //     duration: directionDetailsInfo.durationText,
    //     price: premiumPrice.toString());

    TaxiTypeList tStandard = TaxiTypeList(
        imgUrl: "assets/images/standard.png",
        type: "Standard",
        distance: directionDetailsInfo.distanceText,
        duration: directionDetailsInfo.durationText,
        price: standardPrice.toString());

    taxiList.clear();
    setState(() {
      taxiList.add(tStandard);
      // taxiList.add(tPremium);
    });
  }

  requestARideButton() {
    referenceRideRequest = BookingController.bookRideRequest(
        referenceRideRequest, context, taxiList[selectedTaxi]);

    userReference = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid)
        .child("ride_request");

    userReference!.set("waiting");

    listenToRideRequestStatus();
  }

  listenToRideRequestStatus() {
    developer.log("In listenToRideRequestStatus()", name: "BookRequestTab");
    bool driverAcceptedRideRequest = false;
    referenceRideRequest!.child("status").onValue.listen((event) {
      developer.log(
          "referenceRideRequest.onValue.listen event -> " +
              event.snapshot.value.toString(),
          name: "BookRequestTab");
      setState(() {
        driverAcceptedRideRequest = true;
      });
    });

    tripRideRequestInfoStreamSubscription =
        referenceRideRequest!.onValue.listen((event) async {
      developer.log(
          "tripRideRequestInfoStreamSubscription -> " +
              event.snapshot.value.toString(),
          name: "BookRequestTab");
      if (driverAcceptedRideRequest) {
        if (event.snapshot.value == null) {
          return;
        }
        yourDriverCurrentInfo = UserModel();
        if ((event.snapshot.value as Map)["driverPhone"] != null) {
          setState(() {
            yourDriverCurrentInfo!.mobile =
                (event.snapshot.value as Map)["driverPhone"].toString();
          });
        }

        if ((event.snapshot.value as Map)["driverName"] != null) {
          setState(() {
            yourDriverCurrentInfo!.name =
                (event.snapshot.value as Map)["driverName"].toString();
          });
        }

        if ((event.snapshot.value as Map)["driverLicensePlate"] != null) {
          setState(() {
            yourDriverCurrentInfo!.licensePlate =
                (event.snapshot.value as Map)["driverLicensePlate"].toString();
          });
        }

        if ((event.snapshot.value as Map)["driverId"] != null) {
          setState(() {
            yourDriverCurrentInfo!.id =
                (event.snapshot.value as Map)["driverId"].toString();
          });
        }

        if ((event.snapshot.value as Map)["driverPhone"] != null) {
          setState(() {
            yourDriverCurrentInfo!.mobile =
                (event.snapshot.value as Map)["driverPhone"].toString();
          });
        }

        if ((event.snapshot.value as Map)["status"] != null) {
          userRideRequestStatus =
              (event.snapshot.value as Map)["status"].toString();
        }

        if ((event.snapshot.value as Map)["driverLocation"] != null) {
          double driverCurrentPositionLat = double.parse(
              (event.snapshot.value as Map)["driverLocation"]["latitude"]
                  .toString());

          double driverCurrentPositionLng = double.parse(
              (event.snapshot.value as Map)["driverLocation"]["longitude"]
                  .toString());

          LatLng driverCurrentPositionLatLng =
              LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

          // Status is accepted

          if (userRideRequestStatus == "accepted") {
            assignedDriverInfoUI();
            updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng);
          }

          // Status is taxi has arrived

          if (userRideRequestStatus == "arrived") {
            setState(() {
              driverRideStatus = "Taxi has Arrived";
            });
          }

          // Status is passenger board taxi and taxi is going to drop off location

          if (userRideRequestStatus == "onriderequest") {
            updateReachingTimeToUserDropOffLocation(
                driverCurrentPositionLatLng);
          }
          if (!hasDriver) {
            setState(() {
              hasDriver = true;
            });
          }
          //Status is Driver is dropping off Passenger and has ended the ride request

          if (userRideRequestStatus == "ended") {
            setState(() {
              driverRideStatus = "You have arrived at your destination";
            });
            if ((event.snapshot.value as Map)["price"] != null) {
              String paymentToBeMade =
                  (event.snapshot.value as Map)["price"].toString();

              var response = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext c) =>
                    PayRequestDialog(paymentAmount: paymentToBeMade),
              );

              if (response == "cashPayment") {
                print("await database 1");
                await FirebaseDatabase.instance
                    .ref()
                    .child("users")
                    .child(yourDriverCurrentInfo!.id!)
                    .child("ride_request")
                    .set("idle");

                print("await database 2");
                await FirebaseDatabase.instance
                    .ref()
                    .child("users")
                    .child(currentFirebaseUser!.uid)
                    .child("ride_request")
                    .set("idle");
                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
                print("disconnect");
                setState(() {
                  print("restart app");
                  MyApp.restartApp(context);
                });
              }
            }
          }
        }
      }
    });
  }

  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async {
    developer.log(
        "requestPositionInfo : " + requestPositionInfo.toString() + "\n",
        name: "BookRequestTab >  updateArrivalTimeToUserPickupLocation");
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickUpPosition =
          LatLng(userCurrentLocation!.latitude, userCurrentLocation!.longitude);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              driverCurrentPositionLatLng, userPickUpPosition);

      if (directionDetailsInfo == null) {
        requestPositionInfo = true;
        return;
      }

      setState(() {
        driverRideStatus = "Taxi is arriving in " +
            directionDetailsInfo.durationText.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationLatitude!,
          dropOffLocation.locationLongitude!);

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              driverCurrentPositionLatLng, userDestinationPosition);

      if (directionDetailsInfo == null) {
        requestPositionInfo = true;
        return;
      }

      setState(() {
        driverRideStatus = "Reaching destination in " +
            directionDetailsInfo.durationText.toString();
      });

      requestPositionInfo = true;
    }
  }

  checkIfExistingRideRequest() async {
    developer.log(
        "checkIfExistingRideRequest() rideStatus : ${userModelCurrentInfo!.rideRequestStatus!}\n",
        name: "BookRequestTab");
    if (userModelCurrentInfo!.rideRequestStatus! != "idle") {
      DatabaseReference rideRequestRef =
          FirebaseDatabase.instance.ref().child("ride_request");

      var snapshot = await rideRequestRef.get();

      Map snap = snapshot.value as Map;
      developer.log("snap : " + snap.entries.toString() + "\n",
          name: "BookRequestTab");
      snap.forEach((key, value) async {
        String userId = (value as dynamic)["userId"];
        String status = (value as dynamic)["status"];
        Directions userPickUpAddress = Directions();
        userPickUpAddress.humanReadableAddress =
            (value as dynamic)["sourceAddress"];
        userPickUpAddress.locationName = (value as dynamic)["sourceAddress"];
        userPickUpAddress.locationLatitude =
            double.parse((value as dynamic)["source"]["latitude"]);
        userPickUpAddress.locationLongitude =
            double.parse((value as dynamic)["source"]["longitude"]);

        Directions userDropOffAddress = Directions();
        userDropOffAddress.humanReadableAddress =
            (value as dynamic)["destinationAddress"];
        userDropOffAddress.locationName =
            (value as dynamic)["destinationAddress"];
        userDropOffAddress.locationLatitude =
            double.parse((value as dynamic)["destination"]["latitude"]);
        userDropOffAddress.locationLongitude =
            double.parse((value as dynamic)["destination"]["longitude"]);

        developer.log("userId : " + userId.toString() + "\n",
            name: "BookRequestTab");

        developer.log("status : " + status.toString() + "\n",
            name: "BookRequestTab");

        if (userId == userModelCurrentInfo!.id! && status != "ended") {
          developer.log(
              "Setting referenceRideRequest key : " + key.toString() + "\n",
              name: "BookRequestTab");
          setState(() {
            isRequestingStatus = "waiting";
            googleMapPadding = SizeConfig.screenHeight! * 0.38;
          });
          referenceRideRequest =
              FirebaseDatabase.instance.ref().child("ride_request").child(key);

          Provider.of<AppInfo>(context, listen: false)
              .updatePickUpLocationAddress(userPickUpAddress);

          Provider.of<AppInfo>(context, listen: false)
              .updateDropOffLocationAddress(userDropOffAddress);
          existingRide = true;
          Future.delayed(const Duration(seconds: 2), () {});
          await drawPolyLineFromSourceToDestination();
          listenToRideRequestStatus();
          assignedDriverInfoUI();
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              top: 185,
              bottom: googleMapPadding - bottomPadding,
            ),
            child: GoogleMap(
              padding: EdgeInsets.only(
                bottom: bottomPadding,
                right: 0,
                left: 0,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              markers: markersSet,
              circles: circlesSet,
              polylines: polyLineSet,
              initialCameraPosition:
                  Provider.of<AppInfo>(context, listen: false)
                              .userPickUpLocation !=
                          null
                      ? CameraPosition(
                          target: LatLng(
                              Provider.of<AppInfo>(context, listen: false)
                                  .userPickUpLocation!
                                  .locationLatitude!,
                              Provider.of<AppInfo>(context, listen: false)
                                  .userPickUpLocation!
                                  .locationLongitude!),
                          zoom: 14,
                        )
                      : kSingaporeDefaultLocation,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPadding = 30;
                });

                locateUserPosition();
              },
            ),
          ),
          // UI of Source Location and Destination Location Widget With "Where to go?" as clickable
          sourceAndDestinationWidget(),

          // UI of Selecting a ride after picking a destination location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight + 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      spreadRadius: 2,
                      offset: Offset(1, 0),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Please specify a destination",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          (taxiList.isNotEmpty)
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    height: selectARideContainerHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
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
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: getProportionateScreenHeight(10),
                            ),
                            const Text(
                              "Select a ride",
                              style: TextStyle(fontSize: 18, height: 1.2),
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(180),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: taxiList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selectedTaxi != index)
                                          selectedTaxi = index;
                                      });
                                    },
                                    child: Card(
                                      color: selectedTaxi == index
                                          ? kPrimaryColor
                                          : Colors.grey[300],
                                      elevation: 1,
                                      shadowColor: Colors.grey,
                                      margin: const EdgeInsets.all(4.0),
                                      child: ListTile(
                                        leading: Image.asset(
                                          taxiList[index].imgUrl!,
                                          width: 70,
                                        ),
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              taxiList[index].type!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: selectedTaxi == index
                                                    ? Colors.white
                                                    : kPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "\$" + taxiList[index].price!,
                                              style: TextStyle(
                                                  height: 1.1,
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedTaxi == index
                                                      ? Colors.white
                                                      : kPrimaryColor),
                                            ),
                                            Text(
                                              taxiList[index].duration!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                height: 1.1,
                                                color: selectedTaxi == index
                                                    ? Colors.white70
                                                    : kPrimaryColor,
                                              ),
                                            ),
                                            Text(
                                              taxiList[index].distance!,
                                              style: TextStyle(
                                                height: 1.1,
                                                fontWeight: FontWeight.normal,
                                                color: selectedTaxi == index
                                                    ? Colors.white70
                                                    : kPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: DefaultButton(
                                  text: "Request a ride",
                                  press: () {
                                    if (Provider.of<AppInfo>(context,
                                                listen: false)
                                            .userDropOffLocation !=
                                        null) {
                                      isRequestingStatus = "waiting";
                                      showFindingARideUI();
                                      requestARideButton();

                                      setState(() {
                                        print(
                                            "DEBUG : panel_widget.dart > DefaultButton > bookRideRequest");

                                        // userReference!.onValue
                                        //     .listen((event) async {
                                        //   print(
                                        //       "DEBUG : user ride_request changed to : " +
                                        //           event.snapshot.value
                                        //               .toString());
                                        //   if (event.snapshot.value !=
                                        //           "waiting" ||
                                        //       event.snapshot.value != "idle") {
                                        //     showDialog(
                                        //       context: context,
                                        //       builder: (BuildContext context) =>
                                        //           ProgressDialog(
                                        //         message:
                                        //             "Ride request accepted.. \nPlease wait",
                                        //       ),
                                        //     );
                                        //     var driverId =
                                        //         event.snapshot.value.toString();
                                        //     Future.delayed(
                                        //         Duration(seconds: 30), () {
                                        //       Navigator.pop(context);
                                        //     });
                                        //   }
                                        // });
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Please select a destination");
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          (taxiList.isNotEmpty)

              // UI of Finding a ride after selecting a specific ride type and requesting a ride
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    height: findingARideContainerHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
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
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            AnimatedTextKit(
                              repeatForever: true,
                              animatedTexts: [
                                TyperAnimatedText(
                                  "Finding a ride..",
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                TyperAnimatedText(
                                  "Waiting to get request accepted..",
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              child: Card(
                                color: kPrimaryColor,
                                elevation: 1,
                                shadowColor: Colors.grey,
                                margin: const EdgeInsets.all(4.0),
                                child: ListTile(
                                  leading: Image.asset(
                                    taxiList[selectedTaxi].imgUrl!,
                                    width: 70,
                                  ),
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        taxiList[selectedTaxi].type!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "\$" + taxiList[selectedTaxi].price!,
                                        style: TextStyle(
                                            height: 1.1,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        taxiList[selectedTaxi].duration!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          height: 1.1,
                                          color: selectedTaxi == selectedTaxi
                                              ? Colors.white70
                                              : kPrimaryColor,
                                        ),
                                      ),
                                      Text(
                                        taxiList[selectedTaxi].distance!,
                                        style: TextStyle(
                                          height: 1.1,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(50),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: DefaultButton(
                                  text: "Cancel ride request",
                                  press: () {
                                    if (Provider.of<AppInfo>(context,
                                                listen: false)
                                            .userDropOffLocation !=
                                        null) {
                                      cancelFindingARideUI();
                                      isRequestingStatus = "idle";
                                      setState(() {
                                        print(
                                            "DEBUG : booking_request_panel_widget > Cancel Click");
                                        userReference!.set("idle");
                                        referenceRideRequest!.remove();
                                        userReference!.onDisconnect();
                                        userReference = null;
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Ride cannot be cancelled");
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),

          // UI of assigned taxi driver who have accepted your request
          (hasDriver)
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    height: assignedDriverInfoContainerHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 4,
                          spreadRadius: 2,
                          offset: Offset(1, 0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 0.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    driverRideStatus,
                                    textAlign: TextAlign.center,
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            const Divider(
                              height: 2,
                              thickness: 2,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            // Taxi Driver License Plate
                            Text(
                              yourDriverCurrentInfo!.licensePlate!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            // Taxi Driver Name
                            Text(
                              yourDriverCurrentInfo!.name!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Divider(
                              height: 2,
                              thickness: 2,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final Uri launchUri = Uri(
                                      scheme: 'tel',
                                      path: yourDriverCurrentInfo!.mobile,
                                    );

                                    await launchUrl(launchUri);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.phone_android,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  label: const Text(
                                    "Call Driver",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  sourceAndDestinationWidget() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        decoration: const BoxDecoration(),
        child: Column(
          children: [
            SizedBox(
              height: getProportionateScreenHeight(30),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_location_alt_rounded,
                    color: kPrimaryColor,
                  ),
                  SizedBox(
                    width: getProportionateScreenWidth(12),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: getProportionateScreenWidth(14),
                        ),
                      ),
                      Text(
                        Provider.of<AppInfo>(context).userPickUpLocation != null
                            ? ((Provider.of<AppInfo>(context)
                                            .userPickUpLocation!
                                            .locationName!)
                                        .length >
                                    20)
                                ? (Provider.of<AppInfo>(context)
                                            .userPickUpLocation!
                                            .locationName!)
                                        .substring(0, 20) +
                                    "..."
                                : (Provider.of<AppInfo>(context)
                                    .userPickUpLocation!
                                    .locationName!)
                            : "Your current location",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: getProportionateScreenWidth(16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(10),
            ),
            Divider(
                height: getProportionateScreenHeight(1),
                thickness: getProportionateScreenHeight(1),
                color: Colors.grey),
            SizedBox(
              height: getProportionateScreenHeight(10),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: GestureDetector(
                onTap: () async {
                  //Search Places Screen
                  if (isRequestingStatus != "waiting") {
                    var responseFromSearchScreen = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => SearchPlacesScreen()));
                    print(
                        "\nDEBUG : book_requests_tab > GestureDetector > responseFromSearchScreen" +
                            responseFromSearchScreen.toString());
                    if (responseFromSearchScreen == "obtainedDropOff") {
                      // Draw routes and polyline
                      setState(() {
                        googleMapPadding = SizeConfig.screenHeight! * 0.38;
                      });
                      Future.delayed(Duration(seconds: 1), () async {
                        await drawPolyLineFromSourceToDestination();
                      });
                    }
                  }
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_location_alt_rounded,
                      color: kPrimaryColor,
                    ),
                    SizedBox(
                      width: getProportionateScreenWidth(12),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "To",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: getProportionateScreenWidth(14),
                          ),
                        ),
                        Text(
                          Provider.of<AppInfo>(context).userDropOffLocation !=
                                  null
                              ? ((Provider.of<AppInfo>(context)
                                              .userDropOffLocation!
                                              .locationName!)
                                          .length >
                                      20)
                                  ? (Provider.of<AppInfo>(context)
                                              .userDropOffLocation!
                                              .locationName!)
                                          .substring(0, 20) +
                                      "..."
                                  : (Provider.of<AppInfo>(context)
                                      .userDropOffLocation!
                                      .locationName!)
                              : "Where to go?",
                          style: TextStyle(
                            color: (isRequestingStatus != "waiting")
                                ? Colors.lightBlue
                                : Colors.black54,
                            fontSize: getProportionateScreenWidth(16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(10),
            ),
            Container(
              height: 1,
              decoration: const BoxDecoration(
                color: Colors.grey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
