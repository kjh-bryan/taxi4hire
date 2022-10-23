import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/models/taxi_type_list.dart';
import 'package:taxi4hire/models/user_ride_request.dart';
import 'package:taxi4hire/screens/ride_request/driver_new_ride_request.dart';

DatabaseReference bookRideRequest(DatabaseReference? referenceRideRequest,
    BuildContext context, TaxiTypeList taxiList) {
  print("DEBUG : bookRideRequest > ");
  referenceRideRequest =
      FirebaseDatabase.instance.ref().child("ride_request").push();

  var sourceLocation =
      Provider.of<AppInfo>(context, listen: false).userPickUpLocation;

  var destinationLocation =
      Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

  Map sourceLocationMap = {
    "latitude": sourceLocation!.locationLatitude.toString(),
    "longitude": sourceLocation.locationLongitude.toString(),
  };

  Map destinationLocationMap = {
    "latitude": destinationLocation!.locationLatitude.toString(),
    "longitude": destinationLocation.locationLongitude.toString(),
  };

  Map userInformationMap = {
    "source": sourceLocationMap,
    "destination": destinationLocationMap,
    "time": DateTime.now().toString(),
    "email": userModelCurrentInfo!.email,
    "name": userModelCurrentInfo!.name,
    "sourceAddress": sourceLocation.locationName,
    "destinationAddress": destinationLocation.locationName,
    "mobile": userModelCurrentInfo!.mobile,
    "type": taxiList.type,
    "price": taxiList.price,
    "duration": taxiList.duration,
    "distance": taxiList.distance,
    "userId": userModelCurrentInfo!.id,
    "driverId": "waiting",
  };

  referenceRideRequest.set(userInformationMap);
  print("DEBUG : bookRideRequest > referenceRideRequest.set");

  return referenceRideRequest;
}

// void checkExistingBookRequest(BuildContext context, String userId) {}

void acceptRideRequest(
    BuildContext context, String userId, String rideRequestId) async {
  print(
      "DEBUG > booking_request_tab > accept Request > userId : $userId > rideRequestId : $rideRequestId");

  DatabaseReference rideRequestDetailsReference = FirebaseDatabase.instance
      .ref()
      .child("ride_request")
      .child(rideRequestId);

  final rideRequestDetailsSnapshot = await rideRequestDetailsReference.get();

  DatabaseReference requesterReference = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userId)
      .child("ride_request");
  final requestSnapshot = await requesterReference.get();

  DatabaseReference driverUserReference = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userModelCurrentInfo!.id!)
      .child("ride_request");
  final userSnapshot = await driverUserReference.get();

  DatabaseReference rideRequestDriverIdReference = FirebaseDatabase.instance
      .ref()
      .child("ride_request")
      .child(rideRequestId)
      .child("driverId");
  final rideRequestDriverIdSnapshot = await rideRequestDriverIdReference.get();

  //print(
  //    "DEBUG > booking_request_tab > acceptRequest > requestSnapShot : ${requestSnapshot.value} > userSnapShot : ${userSnapshot.value}> rideRequestSnapshot : ${rideRequestSnapshot.value}");

  if (requestSnapshot.value.toString() == "waiting" &&
      userSnapshot.value.toString() == "idle" &&
      rideRequestDriverIdSnapshot.value.toString() == "waiting") {
    if (rideRequestDriverIdSnapshot.value != null) {
      double sourceLat = double.parse(
          (rideRequestDetailsSnapshot.value! as Map)["source"]["latitude"]);

      double sourceLng = double.parse(
          (rideRequestDetailsSnapshot.value! as Map)["source"]["longitude"]);

      String sourceAddress =
          (rideRequestDetailsSnapshot.value! as Map)["sourceAddress"];

      double destinationLat = double.parse((rideRequestDetailsSnapshot.value!
          as Map)["destination"]["latitude"]);

      double destinationLng = double.parse((rideRequestDetailsSnapshot.value!
          as Map)["destination"]["longitude"]);

      String destinationAddress =
          (rideRequestDetailsSnapshot.value! as Map)["destinationAddress"];

      String userName = (rideRequestDetailsSnapshot.value! as Map)["name"];
      String userPhone = (rideRequestDetailsSnapshot.value! as Map)["mobile"];
      String price =
          (rideRequestDetailsSnapshot.value! as Map)["price"].toString();
      String userId = (rideRequestDetailsSnapshot.value! as Map)["userId"];

      UserRideRequest userRideRequest = UserRideRequest();

      userRideRequest.sourceLatLng = LatLng(sourceLat, sourceLng);
      userRideRequest.sourceAddress = sourceAddress;
      userRideRequest.destinationLatLng =
          LatLng(destinationLat, destinationLng);
      userRideRequest.destinationAddress = destinationAddress;
      userRideRequest.userName = userName;
      userRideRequest.userPhone = userPhone;
      userRideRequest.price = price;
      userRideRequest.userId = userId;
      userRideRequest.rideRequestId = rideRequestId;
      globalRideRequestDetail = userRideRequest;

      driverUserReference.set("accepted");
      rideRequestDetailsReference.child("status").set("accepted");
      rideRequestDriverIdReference.set(userModelCurrentInfo!.id);

      Navigator.pushNamed(context, DriverNewRideRequestScreen.routeName,
          arguments: userRideRequest);
    }
  }
}
