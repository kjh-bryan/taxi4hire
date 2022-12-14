import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/controller/map_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/models/taxi_type_list.dart';
import 'package:taxi4hire/models/user_ride_request.dart';
import 'package:taxi4hire/screens/ride_request/driver_new_ride_request.dart';
import 'dart:developer' as developer;

/*
  Booking Controller to handle events suchs as booking request or accepting a request
  */
class BookingController {
  /*
  Passenger book a ride request, which sends information such as:
    - The location of its current location
    - The destination location 
    - User's particulars such as name, email and mobile.
    - Details of the ride, type of service, price, duration and distace to destination
  to the Realtime Database
  */
  static DatabaseReference bookRideRequest(
      DatabaseReference? referenceRideRequest,
      BuildContext context,
      TaxiTypeList taxiList) {
    developer.log(
        "booking Ride Request by User : " + userModelCurrentInfo!.name!,
        name: "BookingController > bookRideRequest");
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
    developer.log("referenceRideRequest.Set  > userInformationMap",
        name: "BookingController > bookRideRequest");
    return referenceRideRequest;
  }

// void checkExistingBookRequest(BuildContext context, String userId) {}

  /*
    Taxi Driver accepts a ride request, updates the existing record of the ride request:
      - The driver particulars such as Id, name, email and mobile
      - Settings the status to accepted
    to the Realtime Database
    */

  static void acceptRideRequest(
      BuildContext context, String userId, String rideRequestId) async {
    developer.log(
        "Driver Id : " +
            userModelCurrentInfo!.id! +
            "  has accepted Ride Request Id : $rideRequestId",
        name: "BookingController > acceptRideRequest");

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
    final rideRequestDriverIdSnapshot =
        await rideRequestDriverIdReference.get();

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

  static void getRideRequest(BuildContext context) async {
    developer.log("Driver Id : " + userModelCurrentInfo!.id!,
        name: "BookingController > getRideRequest");

    if (userModelCurrentInfo!.rideRequestStatus! != "idle") {
      DatabaseReference rideRequestRef =
          FirebaseDatabase.instance.ref().child("ride_request");

      var snapshot = await rideRequestRef.get();

      Map snap = snapshot.value as Map;
      developer.log("snap : " + snap.entries.toString() + "\n",
          name: "BookRequestTab");
      snap.forEach((key, value) async {
        String userId = (value as dynamic)["userId"];
        String driverId = (value as dynamic)["driverId"];
        String status = (value as dynamic)["status"];

        if (driverId == userModelCurrentInfo!.id! && status != "ended") {
          developer.log("await MapController.locateUserPosition(); ",
              name: "BookingController > getRideRequest");
          await MapController.locateUserPosition();
          String sourceAddress = (value as dynamic)["sourceAddress"];
          double sourceLat =
              double.parse((value as dynamic)["source"]["latitude"]);
          double sourceLng =
              double.parse((value as dynamic)["source"]["longitude"]);

          String destinationAddress = (value as dynamic)["destinationAddress"];
          double destinationLat =
              double.parse((value as dynamic)["destination"]["latitude"]);
          double destinationLng =
              double.parse((value as dynamic)["destination"]["longitude"]);

          String userName = (value as dynamic)["name"];
          String userPhone = (value as dynamic)["mobile"];
          String price = (value as dynamic)["price"];

          String rideRequestId = key;

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

          Navigator.popAndPushNamed(
              context, DriverNewRideRequestScreen.routeName,
              arguments: userRideRequest);
        }
      });
    }
  }
}
