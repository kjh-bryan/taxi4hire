import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/controller/map_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/screens/main_map/main_map.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';

void signInUser(BuildContext context, TextEditingController emailController,
    TextEditingController passwordController, bool remember) async {
  print("Login User -> Show Dialog");
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Logging in.. Please wait..");
      });

  final User firebaseUser;

  print("Login User -> try");
  try {
    print("Login User -> await firebaseAuth");
    final UserCredential userCredential =
        await firebaseAuth.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());
    firebaseUser = userCredential.user!;

    if (firebaseUser != null) {
      if (remember) currentFirebaseUser = firebaseUser;
      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child("users");
      usersRef.child(firebaseUser.uid).once().then((userKey) async {
        final snap = userKey.snapshot;
        print("\nDEBUG : sign_in_form > loginUser > if firebaseUser != null");

        if (snap.value != null) {
          Fluttertoast.showToast(msg: "Logged in successful, Redirecting..");

          // Navigator.popAndPushNamed(context, MainMapView.routeName);
          Navigator.pop(context);
          signInExistingUser(context);
        } else {
          print("No records exist with this email");
          firebaseAuth.signOut();
          Navigator.pop(context);
          signInExistingUser(context);
        }
      });
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      Fluttertoast.showToast(msg: "No user found for that email");
    } else if (e.code == 'wrong-password') {
      Fluttertoast.showToast(msg: "Wrong password provided for that user.");
    } else if (e.code == 'network-request-failed') {
      Fluttertoast.showToast(msg: "Internet currently unavailable.");
    }

    print(e);
    Navigator.pop(context);
  } catch (e) {
    print(e);
    Navigator.pop(context);
  }
}

void signUpUser(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController mobileNoController,
    TextEditingController? licenseNoController,
    int role) async {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Signing up.. Please wait..");
      });

  final User firebaseUser;
  try {
    final UserCredential userCredential =
        await firebaseAuth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());

    firebaseUser = userCredential.user!;

    if (firebaseUser != null) {
      Map userMap = {
        "id": firebaseUser.uid,
        "email": emailController.text.trim(),
        "mobile": mobileNoController.text.trim(),
        "license_plate":
            licenseNoController != null ? licenseNoController.text.trim() : "",
        "role": role,
        "ride_request": "idle"
        //role : 1 as passenger
      };

      DatabaseReference taxiDriversRef =
          FirebaseDatabase.instance.ref().child('users');

      taxiDriversRef.child(firebaseUser.uid).set(userMap);

      currentFirebaseUser = firebaseUser;

      Fluttertoast.showToast(msg: "Registration successful, Redirecting..");

      Navigator.pop(context);
      signInExistingUser(context);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      Fluttertoast.showToast(msg: "The password provided is too weak.");
    } else if (e.code == 'email-already-in-use') {
      Fluttertoast.showToast(msg: "The account already exists for that email.");
    }
    print("Inside FirebaseAuthException catch (e) " + e.toString());
    Navigator.pop(context);
  } catch (e) {
    print(e);
    Navigator.pop(context);
  }
}

signInExistingUser(
  BuildContext context,
) {
  if (firebaseAuth.currentUser != null) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Logging you in..");
        });
    AssistantMethods.readCurrentOnlineUserInfo();
  }
  Timer(const Duration(seconds: 3), () async {
    if (await firebaseAuth.currentUser != null) {
      currentFirebaseUser = firebaseAuth.currentUser;
      // Navigator.popAndPushNamed(context, MainMapView.routeName);
      print("Splash > startTime() > Timer");
      LocationPermission? locationPermission;
      checkIfLocationPermissionAllowed(locationPermission);
      Navigator.pop(context);
      Navigator.popAndPushNamed(context, MainMap.routeName);
      // Navigator.popAndPushNamed(
      //                       context, MainMap.routeName);
    }
  });
}
