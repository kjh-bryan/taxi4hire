import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/components/profile_design_ui.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Profile",
              style: const TextStyle(
                fontSize: 50,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: const SizedBox(
                height: 20,
                child: Divider(
                  color: Colors.grey,
                  height: 2,
                  thickness: 2,
                ),
              ),
            ),
            // Name of user
            Text(
              userModelCurrentInfo!.name!,
              style: const TextStyle(
                fontSize: 40,
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              (userModelCurrentInfo!.role == "0") ? "Driver" : "Passenger",
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.grey,
                height: 2,
                thickness: 2,
              ),
            ),

            const SizedBox(
              height: 38.0,
            ),

            //User's phone

            ProfileDesignUIWidget(
              textInfo: userModelCurrentInfo!.mobile,
              iconData: Icons.phone_android,
            ),

            //User's email
            ProfileDesignUIWidget(
              textInfo: userModelCurrentInfo!.email,
              iconData: Icons.email,
            ),

            // User's role :
            // ProfileDesignUIWidget(
            //   textInfo:
            //       (userModelCurrentInfo!.role == 0) ? "Driver" : "Passenger",
            //   iconData: (userModelCurrentInfo!.role == 0)
            //       ? Icons.local_taxi
            //       : Icons.hail,
            // ),
            (userModelCurrentInfo!.role == "0")
                ? ProfileDesignUIWidget(
                    textInfo: userModelCurrentInfo!.license_plate,
                    iconData: Icons.numbers,
                  )
                : Container(),

            const SizedBox(
              height: 20,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DefaultButton(
                  text: "Sign Out",
                  press: () async {
                    userModelCurrentInfo = null;
                    currentFirebaseUser = null;
                    await firebaseAuth.signOut();
                    Navigator.popAndPushNamed(context, SignInScreen.routeName);
                    Provider.of<AppInfo>(context, listen: false).logOut();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ));
    //
  }
}
