import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/components/default_button.dart';
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
    return Center(
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
    );
  }
}
