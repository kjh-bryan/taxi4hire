import 'package:flutter/material.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/screens/main_map_view/components/body.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';

class MainMapView extends StatefulWidget {
  const MainMapView({Key? key}) : super(key: key);
  static String routeName = "/main_map_view";

  @override
  State<MainMapView> createState() => _MainMapViewState();
}

class _MainMapViewState extends State<MainMapView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
    // return Center(
    //   child: ElevatedButton(
    //     child: Text(
    //       "Sign Out",
    //       style: TextStyle(
    //         color: Colors.black,
    //       ),
    //     ),
    //     onPressed: () {
    //       var f = firebaseAuth.signOut();
    //       print(f);
    //       currentFirebaseUser = null;
    //       Navigator.popAndPushNamed(context, SignInScreen.routeName);
    //     },
    //   ),
    // );
  }
}
