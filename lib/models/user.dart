import 'package:flutter/material.dart';

enum Roles { passenger, driver }

class User {
  final String uid;
  final String email;
  final String mobileNo;
  final String licensePlate;
  final Roles role;

  bool get isPassengerRole => role == Roles.passenger;
  bool get isDriverRole => role == Roles.driver;

  const User({
    required this.uid,
    required this.email,
    required this.mobileNo,
    required this.licensePlate,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      mobileNo: data['mobileNo'] ?? '',
      licensePlate: data['license_plate'] ?? '',
      role: Roles.values[data['role'] ?? 0],
    );
  }
}
