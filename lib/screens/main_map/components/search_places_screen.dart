import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:taxi4hire/assistants/request_assistant.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/map_controller.dart';
import 'package:taxi4hire/models/predicted_places.dart';
import 'package:taxi4hire/screens/main_map/components/place_prediction_tile.dart';
import 'package:taxi4hire/size_config.dart';
import 'dart:developer' as developer;

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces> placesPredictedList = [];

  void findPlacesAutoCompleteSearch(String inputText) async {
    List<PredictedPlaces> newPredictedPlacesList =
        await MapController.findAutoCompletePlaces(
            inputText, placesPredictedList);
    if (newPredictedPlacesList != placesPredictedList) {
      setState(() {
        placesPredictedList = newPredictedPlacesList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //Search place UI
          Container(
            height: getProportionateScreenHeight(160),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: getProportionateScreenHeight(25),
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: kPrimaryColor,
                        ),
                      ),
                      Center(
                        child: Text(
                          "Search Dropoff Location",
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(18),
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(16),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.adjust_sharp,
                        color: kPrimaryColor,
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(18),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (valueType) {
                              if (valueType.isNotEmpty) {
                                findPlacesAutoCompleteSearch(valueType);
                              } else {
                                setState(() {
                                  placesPredictedList.clear();
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Search Here",
                              fillColor: Colors.grey.shade200,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              contentPadding: EdgeInsets.only(
                                left: getProportionateScreenWidth(11),
                                top: getProportionateScreenHeight(8),
                                bottom: getProportionateScreenHeight(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          //Display auto complete places result
          (placesPredictedList.isNotEmpty)
              ? Expanded(
                  child: ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return PlacePredictionTile(
                        predictedPlaces: placesPredictedList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        color: Colors.grey,
                        height: 1,
                        thickness: 1,
                      );
                    },
                    itemCount: placesPredictedList.length,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
