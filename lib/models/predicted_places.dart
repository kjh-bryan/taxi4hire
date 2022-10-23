class PredictedPlaces {
  String? placeId;
  String? mainPlaceDescriptionText;
  String? secondaryPlaceDescriptionText;

  PredictedPlaces(
      {this.placeId,
      this.mainPlaceDescriptionText,
      this.secondaryPlaceDescriptionText});

  PredictedPlaces.fromJson(Map<String, dynamic> jsonData) {
    placeId = jsonData["place_id"];
    mainPlaceDescriptionText = jsonData["structured_formatting"]["main_text"];
    secondaryPlaceDescriptionText =
        jsonData["structured_formatting"]["secondary_text"];
  }
}
