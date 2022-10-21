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
      print(
          "DEBUG : AssistantMethods > searchAddressForGeographicCoordinate > Provider.of<AppInfo>");
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
        print("Email : " + userModelCurrentInfo!.email.toString());
        print("mobile : " + userModelCurrentInfo!.mobile.toString());
        print("role : " + userModelCurrentInfo!.role.toString());
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
      print(
          "DEBUG : AssistantMethods > obtainOriginToDestinationDirection > responseDirectionApi == 'error_occured'");
      return null;
    }
    print(
        "DEBUG : AssistantMethods > obtainOriginToDestinationDirection > Successful");
    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();

    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromSourceToDestination(
      DirectionDetailsInfo directionDetailsInfo, String type) {
    double bookingFees = type.toLowerCase() == "standard" ? 3.30 : 10.00;
    double feesPerDistanceDuration =
        type.toLowerCase() == "standard" ? 0.24 : 0.33;

    double timeTraveledFarePerMinute =
        (directionDetailsInfo.duration_value! / 45) * feesPerDistanceDuration;

    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.distance_value! / 400) * feesPerDistanceDuration;

    double totalFareAmount =
        bookingFees + distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(2));
  }
}
