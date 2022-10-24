import 'package:flutter/material.dart';
import 'package:taxi4hire/screens/sign_up_selection/components/body.dart';

class SignUpSelectionScreen extends StatefulWidget {
  const SignUpSelectionScreen({Key? key}) : super(key: key);

  static String routeName = "/sign_up_selection";

  @override
  State<SignUpSelectionScreen> createState() => _SignUpSelectionScreenState();
}

class _SignUpSelectionScreenState extends State<SignUpSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Body(),
    );
  }
}
