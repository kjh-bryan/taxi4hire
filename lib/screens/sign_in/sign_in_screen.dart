import 'package:flutter/material.dart';
import 'package:taxi4hire/screens/sign_in/components/body.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);
  static String routeName = "/sign_in";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Body(),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          "Sign In",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
    );
  }
}
