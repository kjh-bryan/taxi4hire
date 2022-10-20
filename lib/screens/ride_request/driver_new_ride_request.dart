import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
  UserRideRequest? rideRequestDetail = globalRideRequestDetail;

  assignedDriverToRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("ride_request")
        .child(rideRequestDetail!.rideRequestId!);

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
    return Container();
  }
}
