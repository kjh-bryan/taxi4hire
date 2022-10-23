import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/assistants/request_assistant.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/models/directions.dart';
import 'package:taxi4hire/models/predicted_places.dart';
import 'package:taxi4hire/size_config.dart';
import 'dart:developer' as developer;

class PlacePredictionTile extends StatelessWidget {
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTile({Key? key, this.predictedPlaces}) : super(key: key);

  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const ProgressDialog(
        message: "Setting up drop off location",
      ),
    );

    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${FlutterConfig.get('MAP_API_KEY')}";

    var responsePlaceId =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);
    if (responsePlaceId == "error_occured") {
      developer.log("responsePlaceId == 'error_occured'",
          name: "PlacePredictionTile > getPlaceDirectionDetails");
      return;
    }

    if (responsePlaceId["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responsePlaceId["result"]["name"];
      directions.locationLatitude =
          responsePlaceId["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responsePlaceId["result"]["geometry"]["location"]["lng"];
      directions.locationId = placeId;
      developer.log("responsePlaceId['status'] == 'OK'",
          name: "PlacePredictionTile > getPlaceDirectionDetails");

      developer.log("Location Name : " + directions.locationName!,
          name: "PlacePredictionTile > getPlaceDirectionDetails");

      developer.log(
          "Location Latitude : " + directions.locationLatitude!.toString(),
          name: "PlacePredictionTile > getPlaceDirectionDetails");

      developer.log(
          "Location Longitude : " + directions.locationLongitude!.toString(),
          name: "PlacePredictionTile > getPlaceDirectionDetails");

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      Navigator.pop(context, "obtainedDropOff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        getPlaceDirectionDetails(predictedPlaces!.placeId, context);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            const Icon(
              Icons.add_location,
              color: kPrimaryColor,
            ),
            SizedBox(
              width: getProportionateScreenWidth(14),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: getProportionateScreenHeight(8),
                  ),
                  Text(
                    predictedPlaces!.mainPlaceDescriptionText!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(16),
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(2),
                  ),
                  Text(
                    predictedPlaces!.secondaryPlaceDescriptionText!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(12),
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
