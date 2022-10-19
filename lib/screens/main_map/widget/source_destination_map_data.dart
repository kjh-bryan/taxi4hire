import 'package:geolocator/geolocator.dart';

class SourceDestinationMap {
  Position sourceLocation;
  Position destinationLocation;

  SourceDestinationMap(
      {required this.sourceLocation, required this.destinationLocation});
}
