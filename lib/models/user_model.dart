import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? id;
  String? email;
  String? name;
  String? mobile;
  String? licensePlate;
  String? role;
  String? rideRequestStatus;

  UserModel(
      {this.id,
      this.email,
      this.name,
      this.mobile,
      this.licensePlate,
      this.role,
      this.rideRequestStatus});

  UserModel.fromSnapshot(DataSnapshot snap) {
    id = snap.key;
    email = (snap.value as dynamic)["email"];
    mobile = (snap.value as dynamic)["mobile"];
    name = (snap.value as dynamic)["name"];
    licensePlate = (snap.value as dynamic)["license_plate"];
    role = (snap.value as dynamic)["role"].toString();
    rideRequestStatus = (snap.value as dynamic)["ride_request"].toString();
  }

  // factory User.fromMap(Map<String, dynamic> data) {
  //   return User(
  //     uid: data['uid'] ?? '',
  //     email: data['email'] ?? '',
  //     mobileNo: data['mobileNo'] ?? '',
  //     licensePlate: data['license_plate'] ?? '',
  //     role: Roles.values[data['role'] ?? 0],
  //   );
  // }
}
