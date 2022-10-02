import 'package:flutter/material.dart';
import 'package:taxi4hire/screens/sign_up_selection/components/body.dart';

class SignUpSelectionScreen extends StatelessWidget {
  SignUpSelectionScreen({Key? key}) : super(key: key);

  static String routeName = "/sign_up_selection";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
