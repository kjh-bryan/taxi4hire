import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/models/direction_details_info.dart';
import 'package:taxi4hire/models/taxi_type_list.dart';
import 'package:taxi4hire/screens/main_map/components/booking_request_panel_widget.dart';
import 'package:taxi4hire/screens/main_map/components/search_places_screen.dart';
import 'package:taxi4hire/screens/main_map/widget/current_location_data.dart';
import 'package:taxi4hire/screens/main_map/widget/inherited_widget.dart';
import 'package:taxi4hire/size_config.dart';

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

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(1.3521, 103.8198),
    zoom: 14,
  );

  Position? userCurrentLocation;
  var geoLocator = Geolocator();

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentLocation = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentLocation!.latitude, userCurrentLocation!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            userCurrentLocation!, context);
    print("This is your current readable address : " + humanReadableAddress);
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
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            sourceLatLng, destinationLatLng);

    Navigator.pop(context);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });
    print("\nDEBUG : home_tab > drawPolyLineFromSourceToDestination\n");
    print("\nDEBUG :These are the points = ");
    print("\nDEBUG :" + directionDetailsInfo!.e_points.toString());

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();
    setState(() {
      double premiumPrice =
          AssistantMethods.calculateFareAmountFromSourceToDestination(
              directionDetailsInfo, "premium");
      double standardPrice =
          AssistantMethods.calculateFareAmountFromSourceToDestination(
              directionDetailsInfo, "standard");

      TaxiTypeList tPremium = TaxiTypeList(
          imgUrl: "assets/images/premium.png",
          type: "Premium",
          distance: directionDetailsInfo.distance_text,
          duration: directionDetailsInfo.duration_text,
          price: premiumPrice.toString());

      TaxiTypeList tStandard = TaxiTypeList(
          imgUrl: "assets/images/standard.png",
          type: "Standard",
          distance: directionDetailsInfo.distance_text,
          duration: directionDetailsInfo.duration_text,
          price: standardPrice.toString());

      taxiList.clear();
      taxiList.add(tStandard);
      taxiList.add(tPremium);

      Provider.of<AppInfo>(context, listen: false)
          .updateTaxiListDetails(taxiList);

      Polyline polyline = Polyline(
        color: kPrimaryColor,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    double southWestLat;
    double southWestLong;
    double northEastLat;
    double northEastLong;

    // if (sourceLatLng.latitude > destinationLatLng.latitude &&
    //     sourceLatLng.longitude > destinationLatLng.longitude) {
    //   boundsLatLng =
    //       LatLngBounds(southwest: destinationLatLng, northeast: sourceLatLng);
    // } else if (sourceLatLng.longitude > destinationLatLng.longitude) {
    //   boundsLatLng = LatLngBounds(
    //       southwest: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
    //       northeast:
    //           LatLng(destinationLatLng.latitude, destinationLatLng.longitude));
    // } else if (sourceLatLng.latitude > destinationLatLng.latitude) {
    //   boundsLatLng = LatLngBounds(
    //     southwest:
    //         LatLng(destinationLatLng.latitude, destinationLatLng.longitude),
    //     northeast: LatLng(sourceLatLng.latitude, sourceLatLng.longitude),
    //   );
    // } else {
    //   boundsLatLng =
    //       LatLngBounds(southwest: sourceLatLng, northeast: destinationLatLng);
    // }

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
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 60));

    Marker sourceMarker = Marker(
      markerId: MarkerId("sourceId"),
      infoWindow:
          InfoWindow(title: sourcePosition.locationName, snippet: "From"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationId"),
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
      circleId: CircleId("sourceId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: sourceLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationId"),
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
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      controller: panelController,
      parallaxEnabled: true,
      parallaxOffset: 0.5,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(getProportionateScreenWidth(28)),
      ),
      maxHeight: Provider.of<AppInfo>(context).userDropOffLocation != null
          ? SizeConfig.screenHeight! * 0.4
          : SizeConfig.screenHeight! * 0.06,
      minHeight: Provider.of<AppInfo>(context).userDropOffLocation != null
          ? SizeConfig.screenHeight! * 0.4
          : SizeConfig.screenHeight! * 0.06,
      panelBuilder: (controller) {
        return BookRequestPanelWidget(
          panelController: panelController,
          controller: controller,
        );
      },
      body: Column(
        children: [
          sourceAndDestinationWidget(),
          SizedBox(
            height: Provider.of<AppInfo>(context).userDropOffLocation == null
                ? getProportionateScreenHeight(535)
                : getProportionateScreenHeight(240),
            child: GoogleMap(
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
                      : _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                Provider.of<AppInfo>(context, listen: false)
                    .setBookingRequestPageMapController(
                        newGoogleMapController!);
                locateUserPosition();
              },
            ),
          ),

          // SizedBox(
          //   height: SizeConfig.screenHeight! * 0.04,
          // ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 24),
          //   child: DefaultButton(
          //       text: "Request a ride",
          //       press: () {
          //         if (Provider.of<AppInfo>(context, listen: false)
          //                 .userDropOffLocation !=
          //             null) {
          //           saveRideRequestInformation();
          //         } else {
          //           Fluttertoast.showToast(msg: "Please select a destination");
          //         }
          //       }),
          // ),
        ],
      ),
    );
  }

  sourceAndDestinationWidget() {
    return Column(
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
                        ? (Provider.of<AppInfo>(context)
                                    .userPickUpLocation!
                                    .locationName!)
                                .substring(0, 32) +
                            "..."
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
              if (!Provider.of<AppInfo>(context, listen: false)
                  .requestRideStatus) {
                var responseFromSearchScreen = await Navigator.push(context,
                    MaterialPageRoute(builder: (c) => SearchPlacesScreen()));
                print(
                    "\nDEBUG : book_requests_tab > GestureDetector > responseFromSearchScreen" +
                        responseFromSearchScreen.toString());
                if (responseFromSearchScreen == "obtainedDropOff") {
                  // Draw routes and polyline
                  await drawPolyLineFromSourceToDestination();
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
                      Provider.of<AppInfo>(context).userDropOffLocation != null
                          ? (Provider.of<AppInfo>(context)
                              .userDropOffLocation!
                              .locationName!)
                          : "Where to go?",
                      style: TextStyle(
                        color: (!Provider.of<AppInfo>(context, listen: false)
                                .requestRideStatus)
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
          decoration: BoxDecoration(
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
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
