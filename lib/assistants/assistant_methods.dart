import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/assistants/request_assistant.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/models/direction_details_info.dart';
import 'package:taxi4hire/models/directions.dart';
import 'package:taxi4hire/models/user_model.dart';
import 'dart:developer' as developer;

class AssistantMethods {
  static String mapApiKey = FlutterConfig.get('MAP_API_KEY');

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${mapApiKey}";

    String humanReadableAddress = "";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "error_occured") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);

      developer.log("requestResponse : " + requestResponse.toString(),
          name: "Assistant Methods > searchAddressForGeographicCoordinates");
    }
    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);

        developer.log("Email : " + userModelCurrentInfo!.email.toString(),
            name: "Assistant Methods > readCurrentOnlineUserInfo");

        developer.log("mobile : " + userModelCurrentInfo!.mobile.toString(),
            name: "Assistant Methods > readCurrentOnlineUserInfo");

        developer.log("role : " + userModelCurrentInfo!.role.toString(),
            name: "Assistant Methods > readCurrentOnlineUserInfo");
      }
    });

    return null;
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng sourcePosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${sourcePosition.latitude},${sourcePosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapApiKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "error_occured") {
      developer.log("responseDirectionApi == 'error_occured'",
          name: "Assistant Methods > obtainOriginToDestinationDirection");
      return null;
    }

    developer.log(
        "responseDirectionApi > Sucessfull > User : " +
            userModelCurrentInfo!.name!,
        name: "Assistant Methods > obtainOriginToDestinationDirection");
    developer.log(
        "responseDirectionApi > Sucessfull > User > Response api" +
            responseDirectionApi.toString(),
        name: "Assistant Methods > obtainOriginToDestinationDirection");
    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

    directionDetailsInfo.ePoints =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distanceText =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distanceValue =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.durationText =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.durationValue =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromSourceToDestination(
      DirectionDetailsInfo directionDetailsInfo, String type) {
    double bookingFees = type.toLowerCase() == "standard" ? 3.30 : 10.00;
    double feesPerDistanceDuration =
        type.toLowerCase() == "standard" ? 0.24 : 0.33;

    double timeTraveledFarePerMinute =
        (directionDetailsInfo.durationValue! / 45) * feesPerDistanceDuration;

    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.distanceValue! / 400) * feesPerDistanceDuration;

    double totalFareAmount = bookingFees +
        distanceTraveledFareAmountPerKilometer +
        timeTraveledFarePerMinute;

    return double.parse(totalFareAmount.toStringAsFixed(2));
  }
}
