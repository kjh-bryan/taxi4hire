import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/models/user_ride_request.dart';

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

  assignedDriverToRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("ride_request")
        .child(localRideRequestDetail!.rideRequestId!);

    Map driverLocationDataMap = {
      //Original is driverCurrentPosition?
      "latitude": userCurrentLocation!.latitude.toString(),
      "longitude": userCurrentLocation!.longitude.toString()
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final rideRequestDetail =
        ModalRoute.of(context)!.settings.arguments as UserRideRequest;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: kSingaporeDefaultLocation,
            onMapCreated: (GoogleMapController controller) async {
              _controllerGoogleMap.complete(controller);
              newRideGoogleMapController = controller;
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 18,
                    spreadRadius: .5,
                    offset: Offset(.6, .6),
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
                      "test minutes",
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
                          rideRequestDetail.userName!,
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
                              rideRequestDetail.sourceAddress!,
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
                              rideRequestDetail.destinationAddress!,
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
                        onPressed: () {},
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
                            fontSize: 15,
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
