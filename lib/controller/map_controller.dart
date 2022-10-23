import 'package:geolocator/geolocator.dart';

class MapController {
  static void checkIfLocationPermissionAllowed(
      LocationPermission? _locationPermission) async {
    _locationPermission = await Geolocator.checkPermission();

    if (_locationPermission == LocationPermission.always ||
        _locationPermission == LocationPermission.whileInUse) {
      return;
    }

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();

      if (_locationPermission == LocationPermission.denied) {
        _locationPermission = await Geolocator.requestPermission();
      }
    }
  }
}
