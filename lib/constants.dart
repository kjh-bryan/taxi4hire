import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi4hire/size_config.dart';

const kPrimaryColor = const Color(0xFF296e48);
//const kPrimaryColor = const Color(0xFFFF7643);
const kSecondaryColor = const Color(0xFF2e8b57);
const kPrimaryLightColor = const Color(0xFFFFECDF);
const kLavenderBlushColor = const Color(0xFFcb2821);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);

// const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(26),
  fontWeight: FontWeight.w300,
  color: Colors.black,
  height: 1.5,
);

//Form error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

const String kEmailNullError = "Please enter your email";
const String kInvalidEmailError = "Please enter a valid email";
const String kUsernameNullError = "Please enter your name";
const String kInvalidUsernameError = "Please enter a valid name";
const String kPasswordNullError = "Please enter your password";
const String kInvalidPasswordError = "Please enter a valid password";

const String kConfirmPasswordNullError = "Please re-enter your password";

const String kShortPasswordError = "Password is too short";
const String kMatchPasswordError = "Password does not match";

const String kMobileNoNullError = "Please enter your mobile no.";
const String kInvalidMobileNoError = "Please enter a valid mobile no.";

const String kLicenseNoNullError = "Please enter your license plate number.";
const String kkInvalidLicenseNoError =
    "Please enter a valid license plate number.";

const CameraPosition kSingaporeDefaultLocation = CameraPosition(
  target: LatLng(1.3521, 103.8198),
  zoom: 15,
);
