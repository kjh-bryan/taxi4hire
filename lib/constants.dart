import 'package:flutter/material.dart';

const kPrimaryColor = const Color(0xFF296e48);
//const kPrimaryColor = const Color(0xFFFF7643);
const kPrimaryLightColor = const Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);

const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

//Form error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

const String kEmailNullError = "Please enter your email";
const String kInvalidEmailError = "Please enter a valid email";
const String kUsernameNullError = "Please enter your username";
const String kInvalidUsernameError = "Please enter a valid username";
const String kPasswordNullError = "Please enter your password";
const String kInvalidPasswordError = "Please enter a valid password";
const String kShortPasswordError = "Password is too short";
const String kMatchPasswordError = "Password does not match";
