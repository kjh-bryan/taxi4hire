import 'package:flutter/material.dart';
import 'package:taxi4hire/screens/forget_password/components/body.dart';

class ForgetPasswordScreen extends StatelessWidget {
  static String routeName = "/forget_password";
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Forget Password"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Body(),
    );
  }
}
