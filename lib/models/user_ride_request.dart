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
}
