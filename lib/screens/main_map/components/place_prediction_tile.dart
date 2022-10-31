import 'package:flutter/material.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/map_controller.dart';
import 'package:taxi4hire/models/predicted_places.dart';
import 'package:taxi4hire/size_config.dart';

class PlacePredictionTile extends StatelessWidget {
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTile({Key? key, this.predictedPlaces}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        FocusScope.of(context).unfocus();
        MapController.getPlaceDirectionDetails(
            predictedPlaces!.placeId, context);
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
