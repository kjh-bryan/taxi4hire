import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? id;
  String? email;
  String? name;
  String? mobile;
  String? license_plate;
  String? role;
  String? rideStatus;

  bool get isPassengerRole => role == "1";
  bool get isDriverRole => role == "0";

  UserModel(
      {this.id,
      this.email,
      this.name,
      this.mobile,
      this.license_plate,
      this.role,
      this.rideStatus});

  UserModel.fromSnapshot(DataSnapshot snap) {
    id = snap.key;
    email = (snap.value as dynamic)["email"];
    mobile = (snap.value as dynamic)["mobile"];
    name = (snap.value as dynamic)["name"];
    license_plate = (snap.value as dynamic)["license_plate"];
    role = (snap.value as dynamic)["role"].toString();
    rideStatus = (snap.value as dynamic)["ride_status"].toString();
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
