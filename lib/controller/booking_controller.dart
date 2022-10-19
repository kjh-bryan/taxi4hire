import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';

DatabaseReference bookRideRequest(
    DatabaseReference? referenceRideRequest, BuildContext context) {
  print("DEBUG : bookRideRequest > ");
  referenceRideRequest =
      FirebaseDatabase.instance.ref().child("ride_request").push();

  var sourceLocation =
      Provider.of<AppInfo>(context, listen: false).userPickUpLocation;

  var destinationLocation =
      Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

  Map sourceLocationMap = {
    "latitude": sourceLocation!.locationLatitude.toString(),
    "longtitude": sourceLocation!.locationLongtitude.toString(),
  };

  Map destinationLocationMap = {
    "latitude": destinationLocation!.locationLatitude.toString(),
    "longtitude": destinationLocation!.locationLongtitude.toString(),
  };

  Map userInformationMap = {
    "source": sourceLocationMap,
    "destination": destinationLocationMap,
    "time": DateTime.now().toString(),
    "email": userModelCurrentInfo!.email,
    "sourceAddress": sourceLocation.locationName,
    "destinationAddress": destinationLocation.locationName,
    "driverId": "waiting",
  };

  referenceRideRequest.set(userInformationMap);
  print("DEBUG : bookRideRequest > referenceRideRequest.set");

  return referenceRideRequest;
}
