import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi4hire/models/directions.dart';
import 'package:taxi4hire/models/taxi_type_list.dart';
import 'package:taxi4hire/models/user_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  UserModel? userModelCurrentInfo;
  Set<Marker>? markersSet;
  List<TaxiTypeList>? taxiList;
  bool requestRideStatus = false;
  int tabNumber = 0;

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  void updateTaxiMarkerSets(Set<Marker> markers) {
    markersSet = markers;
    notifyListeners();
  }

  void updateUserModelCurrentInfo(UserModel? userModel) {
    userModelCurrentInfo = userModel;
    notifyListeners();
  }

  void updateRequestRideStatus(bool newRequestRideStatus) {
    requestRideStatus = newRequestRideStatus;
    notifyListeners();
  }

  void updateTabIndex(int newTabNumber) {
    tabNumber = newTabNumber;
    notifyListeners();
  }

  void logOut() {
    userPickUpLocation = null;
    userDropOffLocation = null;
    markersSet = null;
  }
}
