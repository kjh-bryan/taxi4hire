import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi4hire/models/directions.dart';
import 'package:taxi4hire/models/taxi_type_list.dart';
import 'package:taxi4hire/models/user_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  UserModel? userModelCurrentInfo;
  GoogleMapController? googleMapController;
  Set<Marker>? markersSet;
  List<TaxiTypeList>? taxiList;
  bool requestRideStatus = false;

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    print("\nDEBUG : AppInfo > updatePickUpLocationAddress\n");
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    print("\nDEBUG : AppInfo > updateDropOffLocationAddress\n");
    notifyListeners();
  }

  void updateTaxiMarkerSets(Set<Marker> markers) {
    markersSet = markers;
    print("\nDEBUG : AppInfo > updateTaxiMarkerSets\n");
    notifyListeners();
  }

  void updateUserModelCurrentInfo(UserModel? userModel) {
    userModelCurrentInfo = userModel;
    print("\nDEBUG : AppInfo > updateUserModelCurrentInfo\n");
    notifyListeners();
  }

  void updateTaxiListDetails(List<TaxiTypeList> newTaxiList) {
    taxiList = newTaxiList;

    notifyListeners();
  }

  void setBookingRequestPageMapController(
      GoogleMapController newGoogleMapController) {
    googleMapController = newGoogleMapController;
    notifyListeners();
  }

  void updateRequestRideStatus(bool newRequestRideStatus) {
    requestRideStatus = newRequestRideStatus;
    notifyListeners();
  }

  void logOut() {
    userPickUpLocation = null;
    userDropOffLocation = null;
    markersSet = null;
  }
}
