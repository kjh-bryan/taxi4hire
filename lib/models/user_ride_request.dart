import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequest {
  LatLng? sourceLatLng;
  LatLng? destinationLatLng;
  String? sourceAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;

  UserRideRequest(
      {this.sourceLatLng,
      this.destinationLatLng,
      this.sourceAddress,
      this.destinationAddress,
      this.rideRequestId,
      this.userName,
      this.userPhone});

  UserRideRequest.fromSnapshot(DataSnapshot snap) {
    rideRequestId = snap.key;
    sourceLatLng = LatLng(
        double.parse((snap.value as dynamic)["source"]["latitude"]),
        double.parse((snap.value as dynamic)["source"]["longitude"]));
    sourceLatLng = LatLng(
        double.parse((snap.value as dynamic)["destination"]["latitude"]),
        double.parse((snap.value as dynamic)["destination"]["longitude"]));
    sourceAddress = (snap.value as dynamic)["sourceAddress"];
    destinationAddress = (snap.value as dynamic)["desinationAddress"];
    userName = (snap.value as dynamic)["name"];
    userPhone = (snap.value as dynamic)["mobile"];
  }
}
