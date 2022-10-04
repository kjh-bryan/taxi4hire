import 'package:flutter/material.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/screens/main_map_view/main_map_view.dart';
import 'package:taxi4hire/screens/sign_in/components/body.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);
  static String routeName = "/sign_in";

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Future startTime() async {
    if (await firebaseAuth.currentUser != null) {
      currentFirebaseUser = firebaseAuth.currentUser;
      Navigator.popAndPushNamed(context, MainMapView.routeName);
    }
  }

  @override
  void initState() {
    super.initState();

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Body(),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Sign In",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
